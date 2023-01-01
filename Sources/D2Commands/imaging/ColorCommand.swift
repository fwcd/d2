import D2MessageIO
import CairoGraphics

public class ColorCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Previews a color",
        longDescription: "Previews a color by it's hex code",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        do {
            guard let hexCode = UInt32(input, radix: 16) else {
                output.append(errorText: "Please enter a hex code as argument!")
                return
            }
            let isRGB = ((hexCode >> 24) & 0xFF) == 0
            let color = isRGB ? Color(rgb: hexCode) : Color(argb: hexCode)
            let width = 100
            let height = 50
            let image = try CairoImage(width: width, height: height)
            let graphics = CairoContext(image: image)
            graphics.draw(rect: Rectangle(fromX: 0, y: 0, width: Double(width), height: Double(height), color: color, isFilled: true))
            try output.append(image)
        } catch {
            output.append(error, errorText: "Could not create image")
        }
    }
}
