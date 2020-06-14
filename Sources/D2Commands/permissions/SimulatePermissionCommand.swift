import D2Permissions

fileprivate let cancelSubcommand = "cancel"

public class SimulatePermissionCommand: StringCommand {
    public let info = CommandInfo(
        category: .permissions,
        shortDescription: "Simulates a permission",
        requiredPermissionLevel: .admin,
        usesSimulatedPermissionLevel: false
    )
    private let permissionManager: PermissionManager

    public init(permissionManager: PermissionManager) {
        self.permissionManager = permissionManager
    }

	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let author = context.author else {
            output.append(errorText: "No author present")
            return
        }

        if input == cancelSubcommand {
            guard permissionManager[simulated: author] != nil else {
                output.append(errorText: "No simulation was running for you.")
                return
            }

            permissionManager[simulated: author] = nil
            output.append("Successfully stopped simulating the level")
        } else {
            guard let level = PermissionLevel.of(input) else {
                output.append(errorText: "Not a valid permission level: \(input)")
                return
            }
            
            permissionManager[simulated: author] = level
            output.append("Simulating permission level `\(input)` for you. Invoke this command with `\(cancelSubcommand)` to exit the simulation.")
        }
    }
}
