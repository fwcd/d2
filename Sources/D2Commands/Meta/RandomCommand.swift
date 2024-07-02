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

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let author = context.author else {
            await output.append(errorText: "No author is present!")
            return
        }
        let commands = context.registry.compactMap { $0.1.asCommand }.filter { permissionManager.user(author, hasPermission: $0.info.requiredPermissionLevel) }
        guard let command = commands.randomElement() else {
            await output.append(errorText: "No (permitted) commands found!")
            return
        }
        await command.invoke(with: input, output: output, context: context)
    }
}
