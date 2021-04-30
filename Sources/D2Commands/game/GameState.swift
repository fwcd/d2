import D2MessageIO
import Utils

/// Represents a mutable game state. Implementing classes are
/// required to use a value type (struct/enum/immutable class).
public protocol GameState {
    /// A role is a logical player in the game (such as "white" or "black").
    associatedtype Role: RichValueConvertible & Hashable
    /// A hand encapsulates a role's private cards/pieces/... in games with imperfect information.
    associatedtype Hand: RichValueConvertible = EmptyRichValueConvertible
    /// A board contains the pieces/cards that are visible to all players.
    associatedtype Board: RichValueConvertible
    /// A move encapsulates the transition to another game state.
    associatedtype Move: Hashable

    var board: Board { get }
    var currentRole: Role { get }
    var hands: [Role: Hand] { get }
    var playersDescription: String { get }
    var handsDescription: String? { get }

    var winner: Role? { get }
    var isDraw: Bool { get }

    init(players: [GamePlayer]) throws

    func rolesOf(player: GamePlayer) -> [Role]

    func playersOf(role: Role) -> [GamePlayer]

    func isPossible(move: Move, by role: Role) -> Bool

    /// May perform special handling of the move once it's 'committed'
    /// (i.e. played in the actual game, not just simulated as part
    /// of e.g. an alpha-beta-search). Use cases include tracking
    /// a move history or anything that's not essential for computing
    /// possible moves and evaluations.
    mutating func perform(move: Move, by role: Role, options: GameMoveOptions) throws
}

public extension GameState {
    var hands: [Role: Hand] { [:] }
    var handsDescription: String? { nil }
    var isGameOver: Bool { winner != nil || isDraw }

    mutating func perform(move: Move, options: GameMoveOptions = []) throws {
        try perform(move: move, by: currentRole, options: options)
    }

    mutating func perform(move: Move, by role: Role) throws {
        try perform(move: move, by: currentRole, options: [])
    }

    func childState(after move: Move, options: GameMoveOptions = []) throws -> Self {
        try childState(after: move, by: currentRole, options: options)
    }

    func childState(after move: Move, by role: Role, options: GameMoveOptions = []) throws -> Self {
        if options.contains(.skipCheck) || isPossible(move: move, by: role) {
            var next = self
            try next.perform(move: move, by: role, options: options)
            return next
        } else {
            throw GameError.invalidMove("Move `\(move)` is not allowed!")
        }
    }
}
