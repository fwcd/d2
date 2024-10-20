@preconcurrency import CairoGraphics

private let asciiShades = [
    "@", "o", ":", "-", ".", " "
]

public class AsciiArtCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Turns an image into ASCII art",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .image
    public let outputValueType: RichValueType = .code

    private let maxAsciiWidth: Int
    private let maxAsciiHeight: Int
    private let widthScaleFactor: Double // to compensate for the rectangularly sized characters

    public init(maxAsciiWidth: Int = 40, maxAsciiHeight: Int = 15, widthScaleFactor: Double = 0.75) {
        self.maxAsciiWidth = maxAsciiWidth
        self.maxAsciiHeight = maxAsciiHeight
        self.widthScaleFactor = widthScaleFactor
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let image = input.asImage else {
            await output.append(errorText: "Please attach an image!")
            return
        }

        let imageHeight = image.height
        let imageWidth = image.width
        let height = maxAsciiHeight
        let width = min(Int(Double(imageWidth * maxAsciiWidth) * widthScaleFactor) / imageHeight, maxAsciiWidth)
        let asciiArt = (0..<height)
            .map { y in (0..<width)
                .map { x in asciiShade(of: image[(y * imageHeight) / height, (x * imageWidth) / width]) }
                .joined() }
            .joined(separator: "\n")
        await output.append(.code(asciiArt, language: nil))
    }

    private func asciiShade(of color: Color) -> String {
        if color.alpha < 20 {
            return " "
        } else {
            let value = min((Int(color.luminance) * asciiShades.count) / 256, asciiShades.count)
            return asciiShades[value]
        }
    }
}
