import Utils

public class DeleteEmojiCommand: StringCommand {
    public let info = CommandInfo(
        category: .emoji,
        shortDescription: "Deletes an emoji on the current guild",
        helpText: "Syntax: [name]",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let sink = context.sink, let guild = context.guild else {
            await output.append(errorText: "Please make sure that a client and a guild exists!")
            return
        }
        guard !input.isEmpty else {
            await output.append(errorText: "Please mention an emoji name!")
            return
        }
        guard let emojiId = guild.emojis.values.filter({ $0.name == input }).compactMap(\.id).first else {
            await output.append(errorText: "No emoji with the given name `\(input)` found!")
            return
        }

        if (try? await sink.deleteEmoji(from: guild.id, emojiId: emojiId)) ?? false {
            await output.append("Successfully deleted emoji!")
        } else {
            await output.append(errorText: "Could not delete emoji")
        }
    }
}
