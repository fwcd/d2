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
        guard let (_, emoji) = guild.emojis.first(where: { $0.1.name == input }) else {
            output.append(errorText: "Could not find emoji with name `\(input)`")
            return
        }
        if let id = emoji.id {
            output.append("<:\(emoji.name):\(id)>")
        } else {
            output.append(emoji.name)
        }
    }
}
