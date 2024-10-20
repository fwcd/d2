import Logging
import D2MessageIO
import D2Permissions
@preconcurrency import CairoGraphics
@preconcurrency import GIF
import Utils

private let log = Logger(label: "D2Commands.DemoGifCommand")

public class DemoGifCommand: VoidCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Creates a demo GIF",
        longDescription: "Creates an animated GIF for testing purposes",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .gif

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        do {
            let width = 200
            let height = 200
            var gif = GIF(width: width, height: height)

            let angleCount = 4
            let angle = (2.0 * Double.pi) / Double(angleCount)

            for angleIndex in 0..<angleCount {
                log.info("Creating frame \(angleIndex) of \(angleCount)")

                let image = try CairoImage(width: width, height: height)
                let graphics = CairoContext(image: image)
                graphics.rotate(by: Double(angleIndex) * angle)
                graphics.draw(image: try CairoImage(pngFilePath: "Resources/Chess/whiteKnight.png"), at: Vec2(x: 100, y: 100))
                graphics.draw(rect: Rectangle(fromX: 10, y: 10, width: 100, height: 100, rotation: Double(angleIndex) * angle, color: .blue))

                gif.frames.append(.init(image: image, delayTime: 100))

                await Task.yield()
            }

            await output.append(.gif(gif))
        } catch {
            await output.append(error, errorText: "An error occurred while encoding/sending the image")
        }
    }
}
