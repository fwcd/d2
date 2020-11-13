import Foundation
import Logging
import Utils
import Graphics

fileprivate let memeTemplatesFilePath = "local/memeTemplates"
fileprivate let log = Logger(label: "D2Commands.ComposeMemeCommand")

public class ComposeMemeCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Composes a meme template with a custom image",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .image
    public let outputValueType: RichValueType = .image
    private let alphaThreshold: Int

    public init(alphaThreshold: Int = 200) {
        self.alphaThreshold = alphaThreshold
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let image = input.asImage else {
            output.append(errorText: "Please input an image!")
            return
        }

        do {
            let template = try pickMemeTemplate()

            do {
                let (topLeft, bottomRight) = findAlphaRectangle(of: template)
                let composition = try composeMeme(from: template, with: image, between: topLeft, and: bottomRight)
                try output.append(composition)
            } catch {
                output.append(error, errorText: "Could not compose image!")
            }
        } catch {
            output.append(error, errorText: "Could not get meme template. Please make sure that `\(memeTemplatesFilePath)` exists and contains suitable templates.")
        }
    }

    private func pickMemeTemplate() throws -> Image {
        let fileManager = FileManager.default
        let urls = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: memeTemplatesFilePath), includingPropertiesForKeys: nil)
        guard let url = urls.filter({ $0.path.hasSuffix(".png") }).randomElement() else { throw ComposeMemeError.noMemeTemplateFound }
        return try Image(fromPngFile: url)
    }

    private func findAlphaRectangle(of image: Image) -> (Vec2<Int>, Vec2<Int>) {
        var topLeft = image.size
        var bottomRight = Vec2<Int>(both: 0)

        for y in 0..<image.height {
            for x in 0..<image.width {
                let pixel = image[y, x]
                if pixel.alpha <= alphaThreshold {
                    topLeft = Vec2(x: min(x, topLeft.x), y: min(y, topLeft.y))
                    bottomRight = Vec2(x: max(x, bottomRight.x), y: max(y, bottomRight.y))
                }
            }
        }

        log.info("Found alpha rectangle in meme template at (\(topLeft), \(bottomRight))")

        if bottomRight.x < topLeft.x || bottomRight.y < topLeft.y {
            return (Vec2(both: 0), image.size)
        } else {
            return (topLeft, bottomRight)
        }
    }

    private func composeMeme(from template: Image, with image: Image, between topLeft: Vec2<Int>, and bottomRight: Vec2<Int>) throws -> Image {
        let composition = try Image(width: template.width, height: template.height)
        var graphics = CairoGraphics(fromImage: composition)

        graphics.draw(image, at: topLeft.asDouble, withSize: bottomRight - topLeft)
        graphics.draw(template)

        return composition
    }
}
