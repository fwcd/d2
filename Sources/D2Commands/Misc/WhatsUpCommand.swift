import D2MessageIO
import Utils

public class WhatsUpCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Displays a summary of the guild members' status",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let guild = await context.guild else {
            await output.append(errorText: "No guild available")
            return
        }
        let memberActivities = guild.presences
            .flatMap { (id, p) in guild.members[id].map { m in p.activities.map { (m, $0) } } ?? [] }
        await output.append(Embed(
            title: ":circus_tent: Currently Active",
            fields: [
                embedFieldsOf(title: ":satellite: Streaming", for: .stream, amongst: memberActivities),
                embedFieldsOf(title: ":video_game: Gaming", for: .game, amongst: memberActivities),
                embedFieldsOf(title: ":musical_note: Listening", for: .listening, amongst: memberActivities)
            ].flatMap { $0 }
        ))
    }

    private func embedFieldsOf(title: String, for activityType: Presence.Activity.ActivityType, amongst memberActivities: [(Guild.Member, Presence.Activity)]) -> [Embed.Field] {
        let filtered = memberActivities.filter { $0.1.type == activityType }
        let (groups, rest) = Dictionary(grouping: filtered, by: { $0.1.name })
            .sorted(by: descendingComparator { $0.1.count })
            .span { $0.1.count >= 2 }
        let groupFields = groups.map { (name, mas) in
            Embed.Field(name: "\(title): \(name)", value: mas
                .sorted(by: descendingComparator(comparing: { $0.1.timestamps?.interval ?? 0 }, then: { $0.1.state?.count ?? 0 }))
                .filter { $0.1.type == activityType && $0.1.name == name }
                .compactMap { format(activity: $0.1, for: $0.0, showGameName: false) }
                .joined(separator: "\n")
                .truncated(to: 500, appending: "...")
                .nilIfEmpty ?? "_no one currently :(_")
        }
        let restFields = (rest.flatMap { $0.1 }.nilIfEmpty.map { mas in
            [Embed.Field(name: title, value: mas
                .sorted(by: descendingComparator(comparing: { $0.1.name }, then: { $0.1.timestamps?.interval ?? 0 }))
                .filter { $0.1.type == activityType }
                .compactMap { format(activity: $0.1, for: $0.0) }
                .joined(separator: "\n")
                .truncated(to: 500, appending: "...")
                .nilIfEmpty ?? "_no one currently :(_")]
        } ?? [])
        return groupFields + restFields
    }

    private func format(activity: Presence.Activity, for member: Guild.Member, showGameName: Bool = true) -> String? {
        let detail = [
            showGameName ? activity.name : nil,
            activity.assets.flatMap { $0.largeText },
            activity.state,
            activity.timestamps?.interval?.displayString
        ].compactMap { $0 }.joined(separator: " - ").nilIfEmpty
        return detail.map { d in "**\(member.displayName.markdownEscaped)**: \(activity.url.map { "[\(d)](\($0))" } ?? d)" }
    }
}
