import D2MessageIO
import D2Utils

public class WhatsUpCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Displays a summary of the guild members' status",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "No guild available")
            return
        }
        let memberPresences = guild.presences.compactMap { (id, p) in guild.members[id].flatMap { ($0, p) } }
        output.append(Embed(
            title: ":confetti_ball: Currently Active",
            fields: [
                embedFieldsOf(title: ":satellite: Streaming", for: .stream, amongst: memberPresences),
                embedFieldsOf(title: ":joystick: Gaming", for: .game, amongst: memberPresences),
                embedFieldsOf(title: ":headphones: Listening", for: .listening, amongst: memberPresences)
            ].flatMap { $0 }
        ))
    }

    private func embedFieldsOf(title: String, for activityType: Presence.Activity.ActivityType, amongst memberPresences: [(Guild.Member, Presence)]) -> [Embed.Field] {
        let filtered = memberPresences.filter { $0.1.game?.type == activityType }
        let (groups, rest) = Dictionary(grouping: filtered, by: { $0.1.game!.name })
            .sorted(by: descendingComparator { $0.1.count })
            .span { $0.1.count > 2 }
        return groups.map { (name, mps) in
            Embed.Field(name: "\(title): \(name)", value: mps
                .sorted(by: descendingComparator(comparing: { $0.1.game!.timestamps?.interval ?? 0 }, then: { $0.1.game!.state?.count ?? 0 }))
                .compactMap { format(presence: $0.1, for: $0.0, showGameName: false) }
                .joined(separator: "\n")
                .truncate(500, appending: "...")
                .nilIfEmpty ?? "_no one currently :(_")
        } + (rest.flatMap { $0.1 }.nilIfEmpty.map { mps in
            [Embed.Field(name: title, value: mps
                .sorted(by: descendingComparator(comparing: { $0.1.game!.name }, then: { $0.1.game!.timestamps?.interval ?? 0 }))
                .compactMap { format(presence: $0.1, for: $0.0) }
                .joined(separator: "\n")
                .truncate(500, appending: "...")
                .nilIfEmpty ?? "_no one currently :(_")]
        } ?? [])
    }

    private func format(presence: Presence, for member: Guild.Member, showGameName: Bool = true) -> String? {
        let game = presence.game!
        let detail = [
            showGameName ? game.name : nil,
            game.assets.flatMap { $0.largeText },
            game.state,
            game.timestamps?.interval?.displayString
        ].compactMap { $0 }.joined(separator: " - ").nilIfEmpty
        return detail.map { d in "**\(member.displayName)**: \(game.url.map { "[\(d)](\($0))" } ?? d)" }
    }
}