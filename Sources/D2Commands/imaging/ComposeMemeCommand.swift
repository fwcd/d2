import Foundation
import Utils
import Graphics

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
                let (topLeft, bottomRight) = findAlphaRectangle(of: image)
                let composition = try composeMeme(from: template, with: image, between: topLeft, and: bottomRight)
                try output.append(composition)
            } catch {
                output.append(error, errorText: "Could not compose image!")
            }
        } catch {
            output.append(error, errorText: "Could not get meme template")
        }
    }

    private func pickMemeTemplate() throws -> Image {
        let fileManager = FileManager.default
        let urls = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "local/memeTemplates"), includingPropertiesForKeys: nil)
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
                    topLeft = Vec2(x: max(x, topLeft.x), y: min(y, topLeft.y))
                    bottomRight = Vec2(x: max(x, bottomRight.x), y: max(y, bottomRight.y))
                }
            }
        }

        if bottomRight.x > topLeft.x || bottomRight.y > topLeft.y {
            return (Vec2(both: 0), image.size)
        } else {
            return (topLeft, bottomRight)
        }
    }

    private func composeMeme(from template: Image, with image: Image, between topLeft: Vec2<Int>, and bottomRight: Vec2<Int>) throws -> Image {
        // TODO
        fatalError("TODO")
    }
}
