import Utils

fileprivate let alphabetLength: Int = 26
fileprivate let alphabetRange = 0..<alphabetLength
fileprivate let alphabetStart = Unicode.Scalar("a").value

public class CaesarCipherCommand: RegexCommand {
    public let info = CommandInfo(
        category: .coding,
        shortDescription: "Applies a caesar cipher",
        longDescription: "Substitutes each letter in the input by the same letter shifted by n places in the alphabet",
        helpText: "Syntax: [offset] [message]",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text
    public let inputPattern = #/(?<offset>\d+)\s+(?<message>.+)/#

    public init() {}

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        guard let offset = UInt32(input.offset), alphabetRange.contains(Int(offset)) else {
            await output.append(errorText: "Missing or invalid offset for caesar chiffre!")
            return
        }

        await output.append(String(input.message.lowercased().map { shift(character: $0, by: offset) }))
    }

    private func shift(character: Character, by offset: UInt32) -> Character {
        guard let scalar = character.unicodeScalars.first?.value,
            alphabetRange.contains(Int(scalar) - Int(alphabetStart)),
            let shifted = Unicode.Scalar((scalar + offset - alphabetStart) % UInt32(alphabetLength) + alphabetStart) else { return character }
        return Character(shifted)
    }
}
