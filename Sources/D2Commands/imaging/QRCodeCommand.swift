import D2MessageIO
import Graphics
import Utils
import QRCodeGenerator

public class QRCodeCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Generates a QR code",
        longDescription: "Generates a QR code from given text",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        do {
            let qr = try QRCode.encode(text: input, ecl: .medium)
            let scale = 4
            let margin = 4 // in modules
            let imageSize = (qr.size + 2 * margin) * scale
            let image = try Image(width: imageSize, height: imageSize)
            let graphics = CairoGraphics(fromImage: image)

            for y in 0..<qr.size {
                for x in 0..<qr.size {
                    let module = qr.getModule(x: x, y: y)
                    let color: Color = module ? .white : .transparent
                    graphics.draw(Rectangle(
                        fromX: Double((x + margin) * scale),
                        y: Double((y + margin) * scale),
                        width: Double(scale),
                        height: Double(scale),
                        color: color,
                        isFilled: true
                    ))
                }
            }

            try output.append(image)
        } catch {
            output.append(error, errorText: "An error occurred while converting the QR code SVG to an image")
        }
    }
}
