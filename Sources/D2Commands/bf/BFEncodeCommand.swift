import D2MessageIO
import D2Permissions
import Utils

public class BFEncodeCommand: StringCommand {
    public let info = CommandInfo(
        category: .bf,
        shortDescription: "Encodes strings to BF code",
        longDescription: "Encodes a string in BF code such that the string is located beginning at the zeroth cell",
        requiredPermissionLevel: .basic
    )
    private let maxStringLength: Int
    public let outputValueType: RichValueType = .code

    public init(maxStringLength: Int = 30) {
        self.maxStringLength = maxStringLength
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard input.count <= maxStringLength || output.messageLengthLimit == nil else {
            output.append(errorText: "Your string needs to be shorter than \(maxStringLength) characters!")
            return
        }

        let encodedChars = input.map { encode($0) ?? "" }
        let encoded = encodedChars.reduce("") { "\($0)>\($1)" } + String(repeating: "<", count: max(0, encodedChars.count - 1))
        output.append(.code(encoded, language: nil))
    }

    private func encode(_ character: Character) -> String? {
        guard let scalar = character.unicodeScalars.first?.value else { return nil }
        let floorLog = scalar.log2Floor()
        let remaining = scalar - (1 << floorLog)

        return "+" + (0..<Int(floorLog)).map { _ in "/" } + (0..<remaining).map { _ in "+" }
    }
}
