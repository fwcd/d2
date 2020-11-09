import Dispatch

public class BlockForeverCommand: StringCommand {
    public let info = CommandInfo(
        category: .scripting,
        shortDescription: "A simple command that blocks forever. Useful for testing.",
        requiredPermissionLevel: .admin
    )
    private let semaphore = DispatchSemaphore(value: 1)

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        semaphore.wait()
    }
}
