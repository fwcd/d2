import Utils

public class CommandCountCommand: VoidCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Counts the number of available commands",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) {
        let count = context.registry.count(forWhich: { $0.value.asCommand != nil })
        output.append("There are currently \(count) \("command".pluralized(with: count)) available")
    }
}
