import D2Permissions

/// A command that expects no input.
public protocol VoidCommand: Command {
    func invoke(output: any CommandOutput, context: CommandContext) async
}

extension VoidCommand {
    public var inputValueType: RichValueType { .none }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        await invoke(output: output, context: context)
    }
}
