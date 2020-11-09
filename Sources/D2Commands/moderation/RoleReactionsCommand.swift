import D2MessageIO
import Utils

fileprivate let argsPattern = try! Regex(from: "(\\w+)\\s+(\\d+)\\s*(.*)")

public class RoleReactionsCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .moderation,
        shortDescription: "Adds reactions to a message that automatically assign roles",
        requiredPermissionLevel: .vip
    )
    @AutoSerializing private var configuration: RoleReactionsConfiguration
    private var subcommands: [String: (CommandOutput, MessageID, String) -> Void] = [:]

    public init(configuration: AutoSerializing<RoleReactionsConfiguration>) {
        self._configuration = configuration
        subcommands = [
            "attach": { [unowned self] output, messageId, args in
                // TODO
            },
            "detach": { [unowned self] output, messageId, _ in
                // TODO
            }
        ]
        info.helpText = """
            Syntax: `[subcommand] [message id] [args...]`

            For example:
            `attach 123456789012345678 😁=Role a, 👍=Role b`
            `detach 123456789012345678`
            """
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }
    }
}
