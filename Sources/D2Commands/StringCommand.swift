import D2Permissions

/// A command that only expects text-based input (as opposed to e.g. an input embed).
/// Usually, these are commands that expect exactly one argument.
public protocol StringCommand: Command {
    func invoke(with input: String, output: any CommandOutput, context: CommandContext) async
}

extension StringCommand {
    public var inputValueType: RichValueType { .text }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        await invoke(with: input.asText ?? input.asCode ?? "", output: output, context: context)
    }
}
