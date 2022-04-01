import D2Permissions

/// A command that expects no input.
public protocol VoidCommand: Command {
    func invoke(output: any CommandOutput, context: CommandContext)
}

extension VoidCommand {
    public var inputValueType: RichValueType { .none }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        invoke(output: output, context: context)
    }
}
