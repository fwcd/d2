import D2MessageIO

public class AboutCommand: VoidCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Describes D2 itself",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    private let commandPrefix: String

    public init(commandPrefix: String) {
        self.commandPrefix = commandPrefix
    }

    public func invoke(output: any CommandOutput, context: CommandContext) {
        output.append(Embed(
            title: "D2",
            description: """
                **I am a versatile assistant that can perform a wide range of more or less useful tasks.**

                Polls? Board games? Image processing? Linear algebra? Music theory? Jokes? There is probably a command for what you need!

                Need help? Type `\(commandPrefix)help`.
                Need inspiration? Try `\(commandPrefix)commandoftheday`. Or `\(commandPrefix)random` if you're feeling lucky.

                Curious how I was built? Check out [my source code](https://github.com/fwcd/d2)!
                """,
            color: 0xfefefe
        ))
    }
}
