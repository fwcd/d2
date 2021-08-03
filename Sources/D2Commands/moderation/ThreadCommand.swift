import D2MessageIO
import Logging
import Utils

fileprivate let log = Logger(label: "D2Commands.ThreadKeepaliveCommand")

public class ThreadCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .moderation,
        shortDescription: "Configures automatic thread unarchiving",
        requiredPermissionLevel: .vip
    )
    @AutoSerializing private var config: ThreadConfiguration
    private var subcommands: [String: (CommandOutput, Channel, CommandContext) -> Void] = [:]

    public init(config _config: AutoSerializing<ThreadConfiguration>) {
        self._config = _config

        subcommands = [
            "enable-keepalive": { [unowned self] output, channel, _ in
                guard channel.type == .text else {
                    output.append(errorText: "Thread keepalives can only be enabled in guild text channels (whose child threads are considered)")
                    return
                }
                config.keepaliveParentChannelIds.insert(channel.id)
                output.append("Added `\(channel.name)` to thread keepalive parent channels.")
            },
            "disable-keepalive": { [unowned self] output, channel, _ in
                guard channel.type == .text else {
                    output.append(errorText: "Thread keepalives can only be disabled in guild text channels (whose child threads are considered)")
                    return
                }
                config.keepaliveParentChannelIds.remove(channel.id)
                output.append("Removed `\(channel.name)` from thread keepalive parent channels.")
            },
            "archive": { [unowned self] output, channel, context in
                guard channel.isThread else {
                    output.append(errorText: "Only thread channels can be archived, please make sure that you are in a thread")
                    return
                }
                config.permanentlyArchivedThreadIds.insert(channel.id)
                output.append("Added `\(channel.name)` to permanently archived threads.")
                context.client?.modifyChannel(channel.id, with: .init(archived: true)).listenOrLogError { _ in
                    log.info("Permanently archived `\(channel.name)` upon command")
                }
            }
        ]

        info.helpText = """
            Available Subcommands: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))
            """
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let subcommand = subcommands[input] else {
            output.append(errorText: "Subcommand `\(input)` not ")
            return
        }
        guard let channelId = context.channel?.id, let channel = context.client?.channel(for: channelId) else {
            output.append(errorText: "No channel available")
            return
        }

        subcommand(output, channel, context)
    }
}
