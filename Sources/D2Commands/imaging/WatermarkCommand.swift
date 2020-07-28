import D2MessageIO
import D2Graphics
import D2Utils

public class WatermarkCommand: Command {
	public let info = CommandInfo(
		category: .imaging,
		shortDescription: "Adds a watermark to an image",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .compound([.image, .text])
	public let outputValueType: RichValueType = .image
    private let fontSize: Double
    private let padding: Double

    public init(
        fontSize: Double = 28,
        padding: Double = 10
    ) {
        self.fontSize = fontSize
        self.padding = padding
    }

	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		guard let image = input.asImage else {
			output.append(errorText: "Not an image!")
            return
        }

        guard let text = input.asText?.nilIfEmpty else {
            output.append(errorText: "Please enter some text!")
            return
        }

        do {
            let width = image.width
            let height = image.height
            let result = try Image(width: width, height: height)
            var graphics = CairoGraphics(fromImage: result)

            graphics.draw(image)
            graphics.draw(Text(text, withSize: fontSize, at: Vec2(x: padding, y: Double(height) - fontSize - padding), color: Colors.white.with(alpha: 128)))

            output.append(.image(result))
        } catch {
            output.append(error, errorText: "An error occurred while creating a new image")
        }
	}
}
