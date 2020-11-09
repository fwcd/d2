import Utils
import D2Permissions

public class ReRunCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Re-runs the last command",
        requiredPermissionLevel: .vip,
        shouldOverwriteMostRecentPipeRunner: false
    )
    private let permissionManager: PermissionManager
    @Synchronized @Box private var mostRecentPipeRunner: (Runnable, PermissionLevel)?

    public init(permissionManager: PermissionManager, mostRecentPipeRunner: Synchronized<Box<(Runnable, PermissionLevel)?>>) {
        self.permissionManager = permissionManager
        self._mostRecentPipeRunner = mostRecentPipeRunner
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let (pipeRunner, minPermissionLevel) = mostRecentPipeRunner else {
            output.append(errorText: "No commands have been executed yet!")
            return
        }
        guard let author = context.author else {
            output.append(errorText: "No author available")
            return
        }
        guard permissionManager[author] >= minPermissionLevel else {
            output.append(errorText: "You do not have sufficient permissions to run this command pipe!")
            return
        }

        pipeRunner.run()
    }
}
