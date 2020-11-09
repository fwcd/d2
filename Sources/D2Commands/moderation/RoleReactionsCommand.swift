import D2MessageIO
import Utils

fileprivate let argsPattern = try! Regex(from: "(\\w+)\\s+<#(\\d+)>\\s+(\\d+)\\s*(.*)")

public class RoleReactionsCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .moderation,
        shortDescription: "Adds reactions to a message that automatically assign roles",
        requiredPermissionLevel: .vip
    )
    @AutoSerializing private var configuration: RoleReactionsConfiguration
    private var subcommands: [String: (CommandOutput, MessageClient, ChannelID, MessageID, String) -> Void] = [:]

    public init(configuration: AutoSerializing<RoleReactionsConfiguration>) {
        self._configuration = configuration
        subcommands = [
            "attach": { [unowned self] output, client, channelId, messageId, args in
                let mappings = RoleReactionsConfiguration.Mappings(fromString: args, clientName: client.name)
                self.configuration.roleMessages[messageId] = mappings

                for (emoji, _) in mappings {
                    client.createReaction(for: messageId, on: channelId, emoji: emoji)
                }

                output.append("Successfully turned the message into an auto-assigning-role-reacting message.")
            },
            "detach": { [unowned self] output, _, _, messageId, _ in
                self.configuration.roleMessages[messageId] = nil
                output.append("Successfully removed role reactions from the message.")
            }
        ]
        info.helpText = """
            Syntax: `[subcommand] [#channel] [message id] [args...]`

            For example:
            `attach #my-awesome-channel 123456789012345678 😁=Role a, 👍=Role b`
            `detach #my-awesome-channel 123456789012345678`
            """
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }
        guard let client = context.client else {
            output.append(errorText: "No client available")
            return
        }

        let subcommandName = parsedArgs[1]
        let channelId = ID(parsedArgs[2], clientName: client.name)
        let messageId = ID(parsedArgs[3], clientName: client.name)
        let subcommandArgs = parsedArgs[4]

        guard let subcommand = subcommands[subcommandName] else {
            output.append(errorText: "Unknown subcommand `\(subcommandName)`, try one of these: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }

        subcommand(output, client, channelId, messageId, subcommandArgs)
    }
}
