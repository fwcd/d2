import Utils

/// A command that takes a parsed argument structure.
public protocol ArgCommand: StringCommand {
    associatedtype Args: Arg

    /// Fetches the _pattern instantation_ of the required argument format.
    var argPattern: Args { get }

    func invoke(with input: Args, output: any CommandOutput, context: CommandContext) async
}

extension ArgCommand {
    public var inputValueType: RichValueType { .text }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let words = input.split(separator: " ").map { String($0) }
        if let args = Args.parse(from: TokenIterator(words)) {
            await invoke(with: args, output: output, context: context)
        } else {
            await output.append(errorText: "Syntax: `\(argPattern)`")
        }
    }
}
