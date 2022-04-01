import D2Permissions
import Graphics
import GIF
import Utils

public class ToGifCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Converts an image to a GIF",
        longDescription: "Converts a PNG image to a (non-animated) GIF",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .image
    public let outputValueType: RichValueType = .gif
    private let quantizers: [String: (Image) -> ColorQuantization] = [
        "uniform": { UniformQuantization(fromImage: $0) },
        "octree": { OctreeQuantization(fromImage: $0) }
    ]

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let image = input.asImage else {
            output.append(errorText: "Input does not have an image")
            return
        }
        let quantizer = input.asText.flatMap { quantizers[$0]?(image) } ?? OctreeQuantization(fromImage: image)
        let width = image.width
        let height = image.height
        var gif = GIF(width: width, height: height, globalQuantization: quantizer)

        gif.frames.append(.init(image: image, delayTime: 0))
        output.append(.gif(gif))
    }
}
