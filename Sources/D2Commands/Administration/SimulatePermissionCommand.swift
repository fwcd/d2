import D2Permissions

private let cancelSubcommand = "cancel"

public class SimulatePermissionCommand: StringCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Simulates a permission",
        requiredPermissionLevel: .admin,
        usesSimulatedPermissionLevel: false
    )
    private let permissionManager: PermissionManager

    public init(permissionManager: PermissionManager) {
        self.permissionManager = permissionManager
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let author = context.author else {
            await output.append(errorText: "No author present")
            return
        }

        if input == cancelSubcommand {
            guard await permissionManager[simulated: author] != nil else {
                await output.append(errorText: "No simulation was running for you.")
                return
            }

            await permissionManager.update(simulated: author, to: nil)
            await output.append("Successfully stopped simulating the level")
        } else {
            guard let level = PermissionLevel.of(input) else {
                await output.append(errorText: "Not a valid permission level: \(input)")
                return
            }

            await permissionManager.update(simulated: author, to: level)
            await output.append("Simulating permission level `\(input)` for you. Invoke this command with `\(cancelSubcommand)` to exit the simulation.")
        }
    }
}
