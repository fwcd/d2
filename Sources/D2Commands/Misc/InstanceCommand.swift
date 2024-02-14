public class InstanceCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the name of the current D2 instance",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .none
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        let instanceName = context.hostInfo?.instanceName ?? "unknown"
        output.append(instanceName)
    }
}
