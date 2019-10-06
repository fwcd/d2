import D2Permissions
import D2Graphics
import D2Utils

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
        "uniform": { UniformQuantization(fromImage: $0, colorCount: GIF_COLOR_COUNT) },
        "octree": { OctreeQuantization(fromImage: $0, colorCount: GIF_COLOR_COUNT) }
    ]
    
    public init() {}
    
    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let image = input.asImage else {
            output.append("Input does not have an image")
            return
        }
        let quantizer = input.asText.flatMap { quantizers[$0]?(image) } ?? OctreeQuantization(fromImage: image, colorCount: GIF_COLOR_COUNT)
        let width = image.width
        let height = image.height
        var gif = AnimatedGif(width: UInt16(width), height: UInt16(height), globalQuantization: quantizer)

        do {
            try gif.append(frame: image, delayTime: 0)
            gif.appendTrailer()
            output.append(.gif(gif))
        } catch {
            output.append("Could not append frame to GIF")
        }
    }
}
