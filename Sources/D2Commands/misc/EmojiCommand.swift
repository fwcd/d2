import D2MessageIO

public class EmojiCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Outputs a custom emoji by name",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Not in a guild!")
            return
        }
        let formatted = input.split(separator: " ").map { formatEmoji(name: String($0), in: guild) }.joined()
        guard !formatted.isEmpty else {
            output.append(errorText: "Please enter one or more emoji names!")
            return
        }
        output.append(formatted)
   }

   private func formatEmoji(name: String, in guild: Guild) -> String {
       if let (_, emoji) = guild.emojis.first(where: { $0.1.name == name }) {
            return "\(emoji)"
        } else {
            return ":\(name):"
        }
   }
}
