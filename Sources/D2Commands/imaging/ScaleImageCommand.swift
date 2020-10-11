import D2MessageIO
import Graphics
import Utils

public class ScaleImageCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Scales an image or GIF by a factor",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .compound([.either([.image, .gif]), .text])
    public let outputValueType: RichValueType = .either([.image, .gif])

    private let maxWidth: Int
    private let maxHeight: Int

    public init(maxWidth: Int = 800, maxHeight: Int = 800) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let rawFactor = input.asText,
            let factor = Double(rawFactor) else {
            output.append(errorText: "Please enter a scaling factor!")
            return
        }

        do {
            if let img = input.asImage {
                try output.append(.image(scale(image: img, by: factor)))
            } else if var gif = input.asGif {
                gif.frames = try gif.frames.map { try .init(image: scale(image: $0.image, by: factor), delayTime: $0.delayTime) }
                output.append(.gif(gif))
            } else {
                output.append(errorText: "Neither an image nor a GIF!")
            }

        } catch let ScaleError.outOfBounds(msg) {
            output.append(errorText: msg)
        } catch {
            output.append(error, errorText: "An error occurred while creating a new image")
        }
    }

    private enum ScaleError: Error {
        case outOfBounds(String)
    }

    private func scale(image: Image, by factor: Double) throws -> Image {
        let width = Int(Double(image.width) * factor)
        let height = Int(Double(image.height) * factor)
        var scaled = try Image(width: width, height: height)

        guard (0..<maxWidth).contains(width), (0..<maxHeight).contains(height) else {
            throw ScaleError.outOfBounds("Please ensure that your size is within the bounds of \(maxWidth), \(maxHeight)!")
        }

        for y in 0..<height {
            for x in 0..<width {
                scaled[y, x] = image[Int(Double(y) / factor), Int(Double(x) / factor)]
            }
        }

        return scaled
    }
}
