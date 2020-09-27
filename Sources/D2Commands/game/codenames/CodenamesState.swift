import D2MessageIO
import D2Permissions

public struct CodenamesState: GameState, Multiplayer {
    private static let minPlayerCount = 4

    public typealias Role = CodenamesRole
    public typealias Board = CodenamesBoard
    public typealias Move = CodenamesMove

    private let rolePlayers: [Role: [GamePlayer]]
    public var players: [GamePlayer] { rolePlayers.values.flatMap { $0 } }
    public var playersDescription: String {
        CodenamesTeam.allCases
            .map { "\($0.asRichValue.asText ?? "?") (\(playersOf(role: .team($0)).map { playerDescriptionOf(player: $0) }.englishEnumerated()))" }
            .joined(separator: " vs ")
    }

    public private(set) var board = Board()
    public private(set) var currentRole: Role = .team(.red)

    public var possibleMoves: Set<Move> {
        return [] // TODO
    }

    public var winner: Role? { nil } // TODO
    public var isDraw: Bool { false }

    public init(players: [GamePlayer]) throws {
        guard players.count >= Self.minPlayerCount else { throw GameError.invalidPlayerCount("Too few players for Codenames, requires at least \(Self.minPlayerCount) (preferably an even number of players for fairness).") }

        // The first player in each team is assigned the spymaster
        // For more details, see the helpText in CodenamesGame
        let half = players.count / 2
        rolePlayers = [
            .team(.red): Array(players[..<half]),
            .team(.blue): Array(players[half...]),
            .spymaster: [players[0], players[half]]
        ]
    }

    public mutating func perform(move: Move, by role: Role) throws {
        // TODO
    }

    public func playersOf(role: Role) -> [GamePlayer] {
        rolePlayers[role] ?? []
    }

    public func rolesOf(player: GamePlayer) -> [Role] {
        rolePlayers.filter { $0.value.contains(player) }.map(\.key)
    }

    private func spymasterOf(team: CodenamesTeam) -> GamePlayer? {
        rolePlayers[.spymaster]?.first { rolesOf(player: $0).contains(.team(team)) }
    }

    private func playerDescriptionOf(player: GamePlayer) -> String {
        let isSpymaster = rolesOf(player: player).contains(.spymaster)
        let icon = CodenamesRole.spymaster.asRichValue.asText.filter { _ in isSpymaster } ?? "?"
        return [icon, player.username].compactMap { $0 }.joined(separator: " ")
    }
}
