import Utils

public class CommandCountCommand: VoidCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Counts the number of available commands",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        let count = context.registry.entries.count(forWhich: { $0.value.asCommand != nil })
        await output.append("There are currently \(count) \("command".pluralized(with: count)) available")
    }
}
