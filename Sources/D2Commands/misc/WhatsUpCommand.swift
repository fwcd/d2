import D2MessageIO

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
            title: ":satellite: Currently Active",
            fields: [
                Embed.Field(name: ":confetti_ball: Streaming", value: memberPresences
                    .filter { $0.1.game?.type == .stream }
                    .map { format(presence: $0.1, for: $0.0) }
                    .joined(separator: "\n")
                    .nilIfEmpty ?? "_no one is currently streaming :(_"),
                Embed.Field(name: ":joystick: Gaming", value: memberPresences
                    .filter { $0.1.game?.type == .game }
                    .map { format(presence: $0.1, for: $0.0) }
                    .joined(separator: "\n")
                    .nilIfEmpty ?? "_no one is playing a game_"),
                Embed.Field(name: ":headphones: Listening", value: memberPresences
                    .filter { $0.1.game?.type == .listening }
                    .map { format(presence: $0.1, for: $0.0) }
                    .joined(separator: "\n")
                    .nilIfEmpty ?? "_no one is listening to music_")
            ]
        ))
    }

    private func format(presence: Presence, for member: Guild.Member) -> String {
        """
        **\(member.displayName)**\(presence.game.map {
            """
            : \($0.name)\([
                $0.assets.flatMap { $0.largeText },
                $0.state,
                $0.timestamps?.interval?.displayString
            ].compactMap { $0 }.joined(separator: " - ").nilIfEmpty.map { "(\($0))" } ?? "")
            """
        } ?? "")
        """
    }
}