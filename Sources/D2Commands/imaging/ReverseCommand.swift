import D2MessageIO

public class ReverseCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Reverses a GIF",
        longDescription: "Reverses the order of a GIF's frames",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .gif
    public let outputValueType: RichValueType = .gif
    
    public init() {}
    
    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        if case let .gif(gif) = input {
            var reversed = gif
            reversed.frames = gif.frames.reversed()
            output.append(.gif(reversed))
        } else {
            output.append(errorText: "ReverseCommand needs a GIF as input")
        }
    }
}
