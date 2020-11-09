import SwiftyTesseract
import Graphics

public class OCRCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Extracts text from images",
        longDescription: "Extracts text from images through optical character recognition with Tesseract",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .image
    public let outputValueType: RichValueType = .text
    private let tesseract: Tesseract

    public init(languages: [RecognitionLanguage] = [.english, .german]) {
        tesseract = Tesseract(languages: languages)
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
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
