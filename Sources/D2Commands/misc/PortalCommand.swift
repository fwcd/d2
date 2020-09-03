import D2MessageIO
import Logging

fileprivate let log = Logger(label: "D2Commands.PortalCommand")

fileprivate struct Portal {
    let origin: ChannelID
    let originName: String

    var target: ChannelID? = nil
    var targetName: String? = nil

    init(origin: ChannelID, originName: String) {
        self.origin = origin
        self.originName = originName
    }

    func other(_ channelId: ChannelID) -> ChannelID? {
        switch channelId {
            case origin: return target
            case target: return origin
            default: return nil
        }
    }
}

public class PortalCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Opens a portal between two channels",
        longDescription: "Opens a bidirectional connection between two channels that allows the user to send messages back and forth",
        requiredPermissionLevel: .basic,
        subscriptionsUserOnly: false
    )
    private var subcommands: [String: (CommandOutput, CommandContext) -> Void] = [:]
    private var portals: [Portal] = []
    private var halfOpenPortal: Portal? = nil

    public init() {
        subcommands = [
            "open": { [unowned self] output, context in
                guard self.currentPortal(context: context) == nil else {
                    output.append(errorText: "You are already connected to a portal!")
                    return
                }
                if self.halfOpenPortal == nil {
                    self.openNewPortal(output: output, context: context)
                } else {
                    self.connectPortal(output: output, context: context)
                }
            },
            "close": { output, context in
                self.closePortal(output: output, context: context)
            }
        ]
        info.helpText = """
            Syntax: [subcommand]

            Available Subcommands:
            \(subcommands.keys.joined(separator: "\n"))
            """
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let subcommand = subcommands[input] else {
            output.append(errorText: "Unknown subcommand `\(input)`, try one of these: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }
        subcommand(output, context)
    }

	public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id else {
            log.warning("No channel id available, despite being subscribed!")
            return
        }
        guard let portal = currentPortal(context: context) else {
            log.warning("Not connected to a portal, despite being subscribed!")
            return
        }
        guard let otherChannelId = portal.other(channelId) else { return } // Do nothing if portal is only partially connected
        output.append(.text("**\(context.author?.username ?? "Unknown user"):** \(content)"), to: .guildChannel(otherChannelId))
    }

    private func endpointName(context: CommandContext) -> String {
        let channelName = context.channel.flatMap { channel in context.guild.map { "\($0.channels[channel.id]?.name ?? "<unnamed channel>") on server \($0.name)" } } ?? "<unknown channel>"
        let platformName = context.client?.name ?? "<unknown platform>"
        return "\(channelName) (\(platformName))"
    }

    private func currentPortal(context: CommandContext) -> Portal? {
        let channelId = context.channel?.id
        return portals.first(where: { $0.origin == channelId || $0.target == channelId })
    }

    private func openNewPortal(output: CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id else {
            log.warning("Tried to open new portal without a channel being present.")
            return
        }

        halfOpenPortal = Portal(origin: channelId, originName: endpointName(context: context))
        context.subscribeToChannel()

        output.append(":sparkles: Opened portal. Make a portal in another channel to connect!")
    }

    private func connectPortal(output: CommandOutput, context: CommandContext) {
        guard var portal = halfOpenPortal else {
            log.warning("Tried to connect portal without having a half-open portal. This is likely a bug.")
            return
        }
        halfOpenPortal = nil

        guard let channelId = context.channel?.id else {
            output.append(errorText: "Cannot open a portal without a channel.")
            return
        }

        portal.target = channelId
        portal.targetName = self.endpointName(context: context)
        self.portals.append(portal)
        context.subscribeToChannel()

        output.append(":dizzy: You are now connected to `\(portal.originName)`")
        output.append(":dizzy: You are now connected to `\(portal.targetName!)`", to: .guildChannel(portal.origin))
}

    private func closePortal(output: CommandOutput, context: CommandContext) {
        let channelId = context.channel?.id
        let closeMessage = ":comet: Closed portal."

        for (i, portal) in portals.enumerated().reversed() where portal.origin == channelId || portal.target == channelId {
            context.subscriptions.unsubscribe(from: portal.origin)
            output.append(closeMessage, to: .guildChannel(portal.origin))

            if let target = portal.target {
                context.subscriptions.unsubscribe(from: target)
                output.append(closeMessage, to: .guildChannel(target))
            }
            portals.remove(at: i)
        }

        if let portal = halfOpenPortal, channelId == portal.origin {
            context.subscriptions.unsubscribe(from: portal.origin)
            halfOpenPortal = nil
        }
    }
}
