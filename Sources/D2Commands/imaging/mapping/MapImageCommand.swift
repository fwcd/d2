import D2MessageIO
import Graphics
import GIF
import Utils

public class MapImageCommand<M>: Command where M: ImageMapping {
    public private(set) var info = CommandInfo(
        category: .imaging,
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .compound([.either([.image, .gif]), .text])
    public let outputValueType: RichValueType = .either([.image, .gif])

    public init(description: String) {
        info.shortDescription = description
        info.longDescription = description
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        do {
            let args = input.asText
            let mapping = try M.init(args: args)

            if let img = input.asImage {
                try output.append(.image(mapping.apply(to: img)))
            } else if let gif = input.asGif {
                let mappedImages = try gif.frames.map { try mapping.apply(to: $0.image) }
                let width = mappedImages.map(\.width).max() ?? 1
                let height = mappedImages.map(\.height).max() ?? 1
                var newGif = GIF(width: width, height: height)

                for (frame, mappedImage) in zip(gif.frames, mappedImages) {
                    newGif.frames.append(.init(image: mappedImage, delayTime: frame.delayTime))
                }

                output.append(.gif(newGif))
            } else {
                output.append(errorText: "Please input either an image or a GIF!")
            }

        } catch {
            output.append(error, errorText: "An error occurred while performing the image mapping: \(error)")
        }
    }
}
