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
                let (topLeft, bottomRight) = findBoundingBox(in: template) { $0.alpha < alphaThreshold }
                let composition = try composeImage(from: template, with: image, between: topLeft, and: bottomRight)
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
}
