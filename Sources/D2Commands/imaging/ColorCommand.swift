import SwiftDiscord
import D2Graphics

public class ColorCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Previews a color",
        longDescription: "Previews a color by it's hex code",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let width = 100
            let height = 50
            let image = try Image(width: width, height: height)
            var graphics = CairoGraphics(fromImage: image)
            graphics.draw(Rectangle(fromX: 0, y: 0, width: Double(width), height: Double(height), isFilled: true))
            try output.append(image)
        } catch {
            output.append(error, errorText: "Could not create image")
        }
    }
}
