public class RandomUserCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches a random user from the guild",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .mentions

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Not on a guild!")
            return
        }
        guard let userId = guild.members.keys.randomElement(),
              let member = guild.members[userId] else {
            output.append(errorText: "No user found on the guild!")
            return
        }

        output.append(.mentions([member.user]))
    }
}
