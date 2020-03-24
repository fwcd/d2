import SwiftDiscord

public class PortalCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Opens a portal between two channels",
        longDescription: "Opens a bidirectional connection between two channels that allows the user to send messages back and forth",
        requiredPermissionLevel: .vip
    )
    private var subcommands: [String: (CommandOutput, CommandContext) -> Void] = [:]

    public init() {
        subcommands = [
            "open": { [unowned self] output, context in
                context.subscribeToChannel()
                output.append(":sparkles: Opened portal")
            },
            "close": { [unowned self] output, context in
                context.unsubscribeFromChannel()
                output.append(":comet: Closed portal")
            }
        ]
        info.helpText = """
            Syntax: [subcommand]
            
            Available Subcommands:
            \(subcommands.keys.joined(separator: "\n"))
            """
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let subcommand = subcommands[input] else {
            output.append(errorText: "Unknown subcommand `\(input)`, try one of these: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }
        subcommand(output, context)
    }
    
	public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) {
        for channelId in context.subscriptions where channelId != context.channel?.id {
            output.append(.text("**\(context.author.username):** \(content)"), to: .serverChannel(channelId))
        }
    }
}
