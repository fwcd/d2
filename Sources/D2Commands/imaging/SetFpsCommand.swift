import D2MessageIO

public class SetFpsCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Sets a GIF's inverse frame delay",
        helpText: "Syntax: [new fps]",
        requiredPermissionLevel: .basic,
        hidden: true // until fixed
    )
    public let inputValueType: RichValueType = .gif
    public let outputValueType: RichValueType = .gif

    public init() {}

    // TODO: Figure out why this command is currently broken

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

        if var gif = input.asGif {
            gif.frames = gif.frames.map { .init(image: $0.image, delayTime: delayTime, localQuantization: $0.localQuantization, disposalMethod: $0.disposalMethod ?? .clearCanvas) }
            output.append(.gif(gif))
        } else {
            output.append(errorText: "SetFpsCommand needs a GIF as input")
        }
    }
}
