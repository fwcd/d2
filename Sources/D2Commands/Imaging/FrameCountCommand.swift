public class FrameCountCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Fetches a GIF's frame count",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let gif = input.asGif else {
            await output.append(errorText: "Please input a GIF!")
            return
        }
        await output.append(String(gif.frames.count))
    }
}
