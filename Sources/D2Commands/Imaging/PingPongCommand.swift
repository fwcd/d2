import D2MessageIO

public class PingPongCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Loops a GIF back-and-forth",
        longDescription: "Appends the frames of a GIF in reverse order",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .gif
    public let outputValueType: RichValueType = .gif

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        if let gif = input.asGif {
            var pingPonged = gif
            pingPonged.frames += pingPonged.frames.reversed()
            await output.append(.gif(pingPonged))
        } else {
            await output.append(errorText: "PingPongCommand needs a GIF as input")
        }
    }
}
