import D2Utils

/** A command that takes a parsed argument structure. */
public protocol ArgCommand: StringCommand {
    associatedtype Args: Arg
    
    /** Fetches the _pattern instantation_ of the required argument format. */
    var argPattern: Args { get }
    
    func invoke(withArgInput input: Args, output: CommandOutput, context: CommandContext)
}

extension ArgCommand {
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let words = input.split(separator: " ")
        inner.invoke(withArgInput: C.parse(TokenIterator(words)), output: output, context: context)
    }
}
