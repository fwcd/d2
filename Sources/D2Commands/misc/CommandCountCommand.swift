public class CommandCountCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Counts the number of available commands",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let count = context.registry.count(forWhich: { $0.value.asCommand != nil })
        output.append("There are currently \(count) \("command".pluralize(with: count)) available")
    }
}
