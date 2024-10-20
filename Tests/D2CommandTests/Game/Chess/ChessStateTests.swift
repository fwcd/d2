import Testing
@testable import D2Commands

struct ChessStateTests {
    @Test func possibleMoves() throws {
        let state = ChessState(players: [GamePlayer(username: "Mr. White"), GamePlayer(username: "Mr. Black")])
        let initialMoves = state.possibleMoves

        #expect(initialMoves.allSatisfy { $0.color == .white }, "Initial moves should all be white")
        #expect(initialMoves.allSatisfy { $0.isCapture == false }, "Initial moves should not contain captures (or unspecified 'isCapture' fields)")
        #expect(initialMoves.contains(ChessMove(
            pieceType: .pawn,
            color: .white,
            originX: xOf(file: "e"),
            originY: yOf(rank: 2),
            isCapture: false,
            destinationX: xOf(file: "e"),
            destinationY: yOf(rank: 4),
            isEnPassant: false
        )), "Possible moves should contain pawn move e4e6")
        expect(initialMoves, containsMove: "white Nb1c3")

        let secondState = try state.childState(after: move("white e2e4", in: state.possibleMoves)!)
        let secondMoves = secondState.possibleMoves

        #expect(secondMoves.allSatisfy { $0.color == .black }, "Second moves should all be black")
        expect(secondMoves, containsMove: "black e7e6")
        expect(secondMoves, containsMove: "black b7b5")
        expect(secondMoves, containsMove: "black Ng8f6")
    }

    private func expect(_ moves: Set<ChessMove>, containsMove moveDescription: String, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(moves.contains { $0.description == moveDescription }, "Moves should contain '\(moveDescription)', but did not: \(moves)", sourceLocation: sourceLocation)
    }

    private func move(_ description: String, in moves: Set<ChessMove>) -> ChessMove? {
        return moves.first { $0.description == description }
    }
}
