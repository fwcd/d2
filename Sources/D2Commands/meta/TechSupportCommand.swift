import D2Permissions

public class TechSupportCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Pings the bot's admins",
        requiredPermissionLevel: .basic
    )
    private let permissionManager: PermissionManager

    public init(permissionManager: PermissionManager) {
        self.permissionManager = permissionManager
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "No guild available")
            return
        }
        output.append(.mentions(Array(permissionManager.admins(in: guild))))
    }
}
