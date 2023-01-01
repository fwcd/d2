import SwiftyTesseract
import CairoGraphics

fileprivate struct ResourceLanguageModelDataSource: LanguageModelDataSource {
    let path: String
    var pathToTrainedData: String { "Resources\(path)" }
}

public class OCRCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Extracts text from images",
        longDescription: "Extracts text from images through optical character recognition with Tesseract",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .image
    public let outputValueType: RichValueType = .text
    private lazy var tesseract: Tesseract = Tesseract(language: .english, dataSource: ResourceLanguageModelDataSource(path: "/ocr"))

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let image = input.asImage else {
            output.append(errorText: "Please input an image!")
            return
        }

        do {
            let data = try image.pngEncoded()
            let text = try tesseract.performOCR(on: data).get()
            output.append(text)
        } catch {
            output.append(error, errorText: "Could not perform OCR on image!")
        }
    }
}
