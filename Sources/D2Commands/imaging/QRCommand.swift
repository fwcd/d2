import SwiftDiscord
import D2Graphics
import D2Utils
import QRCodeGenerator

public class QRCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Generates a QR code",
        longDescription: "Generates a QR code from given text",
        requiredPermissionLevel: .basic
    )
    let tempDir = TemporaryDirectory()
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let tempFile = tempDir.createFile(named: "qr.xml")
        let svgXml = QRCodeGenerator.getQRCodeAsSVG(input, withTolerance: .Medium)
        tempFile.write(utf8: svgXml)
        
        do {
            let width = 200 // TODO
            let height = 200
            let image = try Image(width: width, height: height)
            let graphics = CairoGraphics(fromImage: image)
            graphics.draw(try SVG(fromSvgFile: tempFile.path, width: width, height: height))
            output.append(image)
        } catch {
            output.append(error, errorText: "An error occurred while converting the QR code SVG to an image")
        }
    }
}
