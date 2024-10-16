import Utils
import D2Permissions

public class ReRunCommand: VoidCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Re-runs the last command",
        requiredPermissionLevel: .vip,
        shouldOverwriteMostRecentPipeRunner: false
    )
    private let permissionManager: PermissionManager
    @Synchronized @Box private var mostRecentPipeRunner: (any AsyncRunnable, PermissionLevel)?

    public init(permissionManager: PermissionManager, mostRecentPipeRunner: Synchronized<Box<(any AsyncRunnable, PermissionLevel)?>>) {
        self.permissionManager = permissionManager
        self._mostRecentPipeRunner = mostRecentPipeRunner
    }

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        guard let (pipeRunner, minPermissionLevel) = mostRecentPipeRunner else {
            await output.append(errorText: "No commands have been executed yet!")
            return
        }
        guard let author = context.author else {
            await output.append(errorText: "No author available")
            return
        }
        guard await permissionManager[author] >= minPermissionLevel else {
            await output.append(errorText: "You do not have sufficient permissions to run this command pipe!")
            return
        }

        await pipeRunner.run()
    }
}
