public class PickProgrammingLanguageCommand: StringCommand {
    public let info = CommandInfo(
        category: .programming,
        shortDescription: "Picks a random programming language",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let value = Words.programmingLanguages.randomElement() else {
            output.append(errorText: "No programming languages found!")
            return
        }

        output.append(value)
    }
}
