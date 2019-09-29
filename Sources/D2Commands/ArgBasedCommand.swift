import D2Utils

/** A command that takes a parsed argument structure. */
public protocol ArgBasedCommand {
    associatedtype Args: Arg
    
    /** Fetches the _pattern instantation_ of the required argument format. */
    var argPattern: Args { get }
    
    func invoke(withArgInput input: Args, output: CommandOutput, context: CommandContext)
}

/**
 * A wrapper struct that conforms to `StringBasedCommand`
 * and parses the argument structure.
 */
public struct ArgCommand<C>: StringBasedCommand where C: ArgBasedCommand {
    private let inner: C
    
    public init(_ inner: C) { self.inner = inner }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let words = input.split(separator: " ")
        inner.invoke(withArgInput: C.parse(TokenIterator(words)), output: output, context: context)
    }
}
