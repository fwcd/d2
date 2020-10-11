import D2MessageIO

public class SetFpsCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Sets a GIF's inverse frame delay",
        helpText: "Syntax: [new fps]",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .gif
    public let outputValueType: RichValueType = .gif

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let raw = input.asText, let fps = Double(raw) else {
            output.append(errorText: info.helpText!)
            return
        }
        guard fps > 0 else {
            output.append(errorText: "FPS cannot be <= 0")
            return
        }

        let delayTime = Int(1.0 / fps)

        if case var .gif(gif) = input {
            gif.frames = gif.frames.map { .init(image: $0.image, delayTime: delayTime, localQuantization: $0.localQuantization, disposalMethod: $0.disposalMethod ?? .clearCanvas) }
            output.append(.gif(gif))
        } else {
            output.append(errorText: "ReverseCommand needs a GIF as input")
        }
    }
}
