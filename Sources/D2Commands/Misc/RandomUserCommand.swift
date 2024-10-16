public class RandomUserCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches a random user from the guild",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .mentions

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let guild = await context.guild else {
            await output.append(errorText: "Not on a guild!")
            return
        }
        guard let userId = guild.members.keys.randomElement(),
              let member = guild.members[userId] else {
            await output.append(errorText: "No user found on the guild!")
            return
        }

        await output.append(.mentions([member.user]))
    }
}
