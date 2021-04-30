import Logging
import D2MessageIO
import Utils
import D2Permissions

fileprivate let log = Logger(label: "D2Commands.ChessState")

public struct ChessState: GameState, FinitePossibleMoves {
    public typealias Role = ChessRole
    public typealias Board = ChessBoard
    public typealias Move = ChessMove

    private let whitePlayer: GamePlayer
    private let blackPlayer: GamePlayer
    public private(set) var board: Board
    public private(set) var currentRole: Role = .white
    public private(set) var moveCount = 0
    public var playersDescription: String { return "`\(whitePlayer.username)` as :white_circle: vs. `\(blackPlayer.username)` as :black_circle:" }

    public var possibleMoves: Set<Move> { return findPossibleMoves(by: currentRole) }
    public var winner: Role? { return ChessRole.allCases.first { isCheckmate($0.opponent) } }
    public var roleInCheck: Role? { return ChessRole.allCases.first { isInCheck($0) } }
    public var isDraw: Bool { return !isInCheck(currentRole) && !canMove(currentRole) }

    /// A very simple evaluation from the perspective of the current role
    /// that only takes the players' pieces' values into account.
    public var evaluation: Double {
        if let winner = winner {
            return (winner == currentRole ? 1 : -1) * Double.infinity
        } else if let roleInCheck = roleInCheck {
            return (roleInCheck == currentRole ? -1 : 1) * 200
        } else {
            let ourValue = Double(board.model.totalValue(for: currentRole))
            let theirValue = Double(board.model.totalValue(for: currentRole.opponent))
            return ourValue - theirValue
        }
    }

    init(whitePlayer: GamePlayer, blackPlayer: GamePlayer, board: Board = Board()) {
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.board = board
    }

    public init(players: [GamePlayer]) {
        self.init(whitePlayer: players[0], blackPlayer: players[1])
    }

    private func locateKing(of role: Role) -> Vec2<Int>? {
        return board.model.positions.first {
            let boardPiece = board.model[$0]
            return boardPiece?.piece.pieceType == .king && boardPiece?.color == role
        }
    }

    private func canMove(_ role: Role) -> Bool {
        return !findPossibleMoves(by: role).isEmpty
    }

    private func isCheckmate(_ role: Role) -> Bool {
        return isInCheck(role) && !canMove(role)
    }

    private func isInCheck(_ role: Role) -> Bool {
        guard let king = locateKing(of: role) else {
            log.error("Could not test if \(role) is in check without a king")
            return false
        }
        let opponent: Role = role.opponent
        let opponentPositions: [Vec2<Int>] = board.model.positions
            .compactMap {
                let piece = board.model[$0]
                return (piece?.color == opponent) ? $0 : nil
            }

        return opponentPositions
            .contains { pos in findPossibleMoves(at: pos, by: opponent, testForChecks: false).contains { $0.destination == king } }
    }

    private func findPossibleMoves(by role: Role, testForChecks: Bool = true) -> Set<Move> {
        return Set(board.model.positions
            .filter { board.model[$0]?.color == role }
            .flatMap { findPossibleMoves(at: $0, by: role, testForChecks: testForChecks) })
    }

    /// Tests whether the given move leads to situation in which the given role is in check.
    private func causesKingInCheck(_ move: Move, for role: Role) -> Bool {
        var stateAfterMove = self
        do {
            try stateAfterMove.performDirectly(move: move)
        } catch {
            log.error("Could not spawn child state while testing whether a move causes a check: \(error)")
            return false
        }
        return stateAfterMove.isInCheck(role)
    }

    /// Tests whether the given move leads to situation in which the given role is checkmate/loses the game.
    private func causesCheckmate(_ move: Move, for role: Role) -> Bool {
        var stateAfterMove = self
        do {
            try stateAfterMove.performDirectly(move: move)
        } catch {
            log.error("Could not spawn child state while testing whether a move causes a checkmate: \(error)")
            return false
        }
        return stateAfterMove.isCheckmate(role)
    }

    private func findPossibleMoves(at position: Vec2<Int>, by role: Role, testForChecks: Bool = true) -> Set<Move> {
        guard let piece = board.model[position] else { return [] }
        let pieceTypeBoard = board.model.pieceTypes
        let isInCheck: Bool

        if testForChecks {
            isInCheck = (roleInCheck == role)
        } else {
            isInCheck = false
        }

        let unfilteredMoves: [Move] = piece.piece.possibleMoves(from: position, board: pieceTypeBoard, role: role, moved: piece.moved, isInCheck: isInCheck)

        for move in unfilteredMoves {
            guard move.pieceType != nil else { fatalError("ChessPiece returned move without 'pieceType' (invalid according to the contract)") }
            guard move.color != nil else { fatalError("ChessPiece returned move without 'color' (invalid according to the contract)") }
            guard move.origin != nil else { fatalError("ChessPiece returned move without 'origin' (invalid according to the contract)") }
            guard move.destination != nil else { fatalError("ChessPiece returned move without 'destination' (invalid according to the contract)") }
        }

        let moves: [Move] = unfilteredMoves
            .filter { pieceTypeBoard.isInBounds($0.destination!) }
            .compactMap { // Captures
                let destinationPiece = board.model[$0.destination!]
                let hasAssociatedCaptures = !$0.associatedCaptures.isEmpty
                if (destinationPiece?.color != role) || hasAssociatedCaptures {
                    var move = $0
                    move.isCapture = (destinationPiece?.color == role.opponent) || hasAssociatedCaptures
                    return move
                }
                return nil
            }
            .filter {
                if testForChecks {
                    return !causesKingInCheck($0, for: role)
                } else {
                    return true
                }
            }
            .map { (it: Move) -> Move in // Checks/checkmates
                var move: Move = it

                if testForChecks {
                    if causesCheckmate(move, for: role.opponent) {
                        move.checkType = .checkmate
                    } else if causesKingInCheck(move, for: role.opponent) {
                        move.checkType = .check
                    }
                }

                return move
            }

        return Set(moves)
    }

    public mutating func perform(move unresolvedMove: Move, by role: Role) throws {
        try performDirectly(move: try unambiguouslyResolve(move: unresolvedMove))
    }

    private mutating func performDirectly(move: Move) throws {
        try board.model.perform(move: move)
        currentRole = currentRole.opponent
        moveCount += 1
    }

    func resolve(move: Move) -> [Move] {
        return possibleMoves
            .filter { $0.matches(move) }
    }

    func unambiguouslyResolve(move unresolvedMove: Move) throws -> Move {
        let resolvedMoves = resolve(move: unresolvedMove)
        guard resolvedMoves.count != 0 else { throw GameError.invalidMove("Move is not allowed: `\(unresolvedMove)`") }
        guard resolvedMoves.count == 1 else { throw GameError.ambiguousMove("Move is ambiguous: `\(unresolvedMove)` could be one of `\(resolvedMoves)`") }
        return resolvedMoves.first!
    }

    public func playersOf(role: Role) -> [GamePlayer] {
        switch role {
            case .white: return [whitePlayer]
            case .black: return [blackPlayer]
        }
    }

    public func rolesOf(player: GamePlayer) -> [Role] {
        var roles = [Role]()

        if player == whitePlayer { roles.append(.white) }
        if player == blackPlayer { roles.append(.black) }

        return roles
    }
}
