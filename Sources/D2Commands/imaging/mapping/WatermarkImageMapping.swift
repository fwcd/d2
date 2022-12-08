import Graphics
import Utils

public struct WatermarkImageMapping: ImageMapping {
    private let fontSize: Double = 28
    private let padding: Double = 10
    private let text: String

    private enum WatermarkError: Error {
        case noText(String)
    }

    public init(args: String?) throws {
        guard let text = args?.nilIfEmpty else {
            throw WatermarkError.noText("Please enter some text!")
        }
        self.text = text
    }

    public func apply(to image: Image) throws -> Image {
        let width = image.width
        let height = image.height
        let result = try Image(width: width, height: height)
        let graphics = CairoGraphics(fromImage: result)

        graphics.draw(image)
        graphics.draw(Text(text, withSize: fontSize, at: Vec2(x: padding, y: Double(height) - fontSize - padding), color: .white.with(alpha: 128)))

        return result
    }
}
