/// A command that parses its input using a regular expression.
public protocol RegexCommand: StringCommand {
    associatedtype Input

    /// The pattern to parse from the input.
    var inputPattern: Regex<Input> { get }

    func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async
}

extension RegexCommand {
    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let parsedInput = try? inputPattern.firstMatch(in: input) else {
            await output.append(errorText: "Could not parse input\(info.helpText.map { ": \($0)" } ?? "")")
            return
        }
        await invoke(with: parsedInput.output, output: output, context: context)
    }
}
