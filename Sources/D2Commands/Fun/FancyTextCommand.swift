import Utils

public class FancyTextCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Stylizes text using special Unicode symbols",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let fancyAlphabet = FancyTextConverter.Alphabet.allCases.randomElement()!
        let fancyText = FancyTextConverter().convert(input, to: fancyAlphabet)
        await output.append(fancyText)
    }
}
