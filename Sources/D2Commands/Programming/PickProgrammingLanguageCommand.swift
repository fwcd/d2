import D2Datasets

public class PickProgrammingLanguageCommand: StringCommand {
    public let info = CommandInfo(
        category: .programming,
        shortDescription: "Picks a random programming language",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let value = Words.programmingLanguages.randomElement() else {
            await output.append(errorText: "No programming languages found!")
            return
        }

        await output.append(value)
    }
}
