import Foundation
import D2MessageIO
import D2Permissions

public class QuitCommand: VoidCommand {
    public let info = CommandInfo(
        category: .administration,
        shortDescription: "Quits D2's process",
        longDescription: "Terminates the running process",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        await output.append(":small_red_triangle_down: Quitting D2")
        raise(SIGINT)
    }
}
