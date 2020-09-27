import D2MessageIO
import D2Utils

/**
 * Represents a mutable game state. Implementing classes are
 * required to use a value type (struct/enum/immutable class).
 */
public protocol GameState {
    /** A role is a logical player in the game (such as "white" or "black"). */
    associatedtype Role: RichValueConvertible & Hashable
    /** A hand encapsulates a role's private cards/pieces/... in games with imperfect information. */
    associatedtype Hand: RichValueConvertible = EmptyRichValueConvertible
    /** A board contains the pieces/cards that are visible to all players. */
    associatedtype Board: RichValueConvertible
    /** A move encapsulates the transition to another game state. */
    associatedtype Move: Hashable

    var board: Board { get }
    var currentRole: Role { get }
    var hands: [Role: Hand] { get }
    var possibleMoves: Set<Move> { get }
    var playersDescription: String { get }
    var handsDescription: String? { get }

    var winner: Role? { get }
    var isDraw: Bool { get }

    init(players: [GamePlayer]) throws

    func rolesOf(player: GamePlayer) -> [Role]

    func playersOf(role: Role) -> [GamePlayer]

    func isPossible(move: Move, by role: Role) -> Bool

    mutating func perform(move: Move, by role: Role) throws
}

public extension GameState {
    var hands: [Role: Hand] { [:] }
    var handsDescription: String? { nil }

    func isPossible(move: Move, by role: Role) -> Bool { possibleMoves.contains(move) }

    func childState(after move: Move) throws -> Self {
        try childState(after: move, by: currentRole)
    }

    func childState(after move: Move, by role: Role) throws -> Self {
        if isPossible(move: move, by: role) {
            var next = self
            try next.perform(move: move, by: role)
            return next
        } else {
            throw GameError.invalidMove("Move `\(move)` is not in `possibleMoves`")
        }
    }
}
