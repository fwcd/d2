import Utils

public class DeleteEmojiCommand: StringCommand {
    public let info = CommandInfo(
        category: .emoji,
        shortDescription: "Deletes an emoji on the current guild",
        helpText: "Syntax: [name]",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let sink = context.sink, let guild = context.guild else {
            output.append(errorText: "Please make sure that a client and a guild exists!")
            return
        }
        guard !input.isEmpty else {
            output.append(errorText: "Please mention an emoji name!")
            return
        }
        guard let emojiId = guild.emojis.values.filter({ $0.name == input }).compactMap(\.id).first else {
            output.append(errorText: "No emoji with the given name `\(input)` found!")
            return
        }

        sink.deleteEmoji(from: guild.id, emojiId: emojiId)
            .listen {
                if (try? $0.get()) ?? false {
                    output.append("Successfully deleted emoji!")
                } else {
                    output.append(errorText: "Could not delete emoji")
                }
            }
    }
}
