import D2NetAPIs

public class TruthOrDareCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Plays the game 'truth or dare'",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text
    private let type: TruthOrDareQuery.TDType?

    public init(type: TruthOrDareQuery.TDType? = nil) {
        self.type = type
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let category = TruthOrDareQuery.Category(rawValue: input) ?? TruthOrDareQuery.Category.allCases.randomElement()!
        let type = self.type ?? TruthOrDareQuery.TDType.allCases.randomElement()!

        do {
            let tod = try await TruthOrDareQuery(category: category, type: type).perform()
            await output.append(tod.text)
        } catch {
            await output.append(error, errorText: "Could not fetch truth/dare")
        }
    }
}
