import D2Graphics

fileprivate let asciiShades = [
    "#", "&", "O", "X", "+", "-", ".", " "
]

public class AsciiArtCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Turns an image into ASCII art",
        requiredPermissionLevel: .basic
    )
	public let inputValueType: RichValueType = .image
	public let outputValueType: RichValueType = .code

    private let width: Int
    private let height: Int

    public init(width: Int = 40, height: Int = 15) {
        self.width = width
        self.height = height
    }

    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let image = input.asImage else {
            output.append(errorText: "Please attach an image!")
            return
        }

        let imageWidth = image.width
        let imageHeight = image.height
        let asciiArt = (0..<height)
            .map { y in (0..<width)
                .map { x in asciiShade(of: image[(y * imageHeight) / height, (x * imageWidth) / width]) }
                .joined() }
            .joined(separator: "\n")
        output.append(.code(asciiArt, language: nil))
    }

    private func asciiShade(of color: Color) -> String {
        let value = min((Int(color.luminance) * asciiShades.count) / 256, asciiShades.count)
        return asciiShades[value]
    }
}
