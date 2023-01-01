import CairoGraphics
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

    public func apply(to image: CairoImage) throws -> CairoImage {
        let width = image.width
        let height = image.height
        let result = try CairoImage(width: width, height: height)
        let graphics = CairoContext(image: result)

        graphics.draw(image: image)
        graphics.draw(text: Text(text, withSize: fontSize, at: Vec2(x: padding, y: Double(height) - fontSize - padding), color: .white.with(alpha: 128)))

        return result
    }
}
