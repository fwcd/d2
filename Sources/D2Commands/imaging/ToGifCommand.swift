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
    
    public init() {}
    
    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        if case let .image(image) = input {
            let width = image.width
            let height = image.height
            var gif = AnimatedGif(width: UInt16(width), height: UInt16(height))
            do {
                try gif.append(frame: image, delayTime: 0)
                gif.appendTrailer()
                output.append(.gif(gif))
            } catch {
                output.append("Could not append frame to GIF")
            }
        } else {
            output.append("Error: Input is not an image")
        }
    }
}
