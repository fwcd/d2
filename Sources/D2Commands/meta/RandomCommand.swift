import D2Permissions

public class RandomCommand: Command {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Invokes a random command",
        requiredPermissionLevel: .basic
    )
    private let permissionManager: PermissionManager

    public init(permissionManager: PermissionManager) {
        self.permissionManager = permissionManager
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let author = context.author else {
            output.append(errorText: "No author is present!")
            return
        }
        let commands = context.registry.compactMap { $0.1.asCommand }.filter { permissionManager.user(author, hasPermission: $0.info.requiredPermissionLevel) }
        guard let command = commands.randomElement() else {
            output.append(errorText: "No (permitted) commands found!")
            return
        }
        command.invoke(with: input, output: output, context: context)
    }
}
