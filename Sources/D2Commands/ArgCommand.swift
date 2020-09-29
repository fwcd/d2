import Utils

/** A command that takes a parsed argument structure. */
public protocol ArgCommand: StringCommand {
    associatedtype Args: Arg

    /** Fetches the _pattern instantation_ of the required argument format. */
    var argPattern: Args { get }

    func invoke(with input: Args, output: CommandOutput, context: CommandContext)
}

extension ArgCommand {
    public var inputValueType: RichValueType { .text }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        let words = input.split(separator: " ").map { String($0) }
        if let args = Args.parse(from: TokenIterator(words)) {
            invoke(with: args, output: output, context: context)
        } else {
            output.append(errorText: "Syntax: `\(argPattern)`")
        }
    }
}
