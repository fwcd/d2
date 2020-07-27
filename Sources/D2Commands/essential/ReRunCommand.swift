import D2Utils
import D2Permissions

public class ReRunCommand: StringCommand {
    public let info = CommandInfo(
        category: .essential,
        shortDescription: "Re-runs the last command",
        requiredPermissionLevel: .admin // TODO: Check permissions
    )
    private let permissionManager: PermissionManager
    @Box private var mostRecentPipeRunner: Runnable?

    public init(permissionManager: PermissionManager, mostRecentPipeRunner: Box<Runnable?>) {
        self.permissionManager = permissionManager
        self._mostRecentPipeRunner = mostRecentPipeRunner
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let pipeRunner = mostRecentPipeRunner else {
            output.append(errorText: "No commands have been executed yet!")
            return
        }

        pipeRunner.run()
    }
}
