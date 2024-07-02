import D2MessageIO
import Logging
import Utils

fileprivate let log = Logger(label: "D2Commands.ThreadKeepaliveCommand")

public class ThreadCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .moderation,
        shortDescription: "Configures threads in this channel or the current thread",
        requiredPermissionLevel: .vip
    )
    @Binding private var config: ThreadConfiguration
    private var subcommands: [String: (CommandOutput, Channel, CommandContext) async -> Void] = [:]

    public init(@Binding config: ThreadConfiguration) {
        self._config = _config

        subcommands = [
            "enable-keepalive": { output, channel, _ in
                guard channel.type == .text else {
                    await output.append(errorText: "Thread keepalives can only be enabled in guild text channels (whose child threads are considered)")
                    return
                }
                config.keepaliveParentChannelIds.insert(channel.id)
                await output.append("Added `\(channel.name)` to thread keepalive parent channels.")
            },
            "disable-keepalive": { output, channel, _ in
                guard channel.type == .text else {
                    await output.append(errorText: "Thread keepalives can only be disabled in guild text channels (whose child threads are considered)")
                    return
                }
                config.keepaliveParentChannelIds.remove(channel.id)
                await output.append("Removed `\(channel.name)` from thread keepalive parent channels.")
            },
            "archive": { output, channel, context in
                guard channel.isThread else {
                    await output.append(errorText: "Only thread channels can be archived, please make sure that you are in a thread")
                    return
                }
                config.permanentlyArchivedThreadIds.insert(channel.id)
                await output.append("Added `\(channel.name)` to permanently archived threads.")
                do {
                    try await context.sink?.modifyChannel(channel.id, with: .init(archived: true))
                    log.info("Permanently archived `\(channel.name)` upon command")
                } catch {
                    await output.append(error, errorText: "Could not archive `\(channel.name)` permanently")
                }
            }
        ]

        info.helpText = """
            Available Subcommands: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))
            """
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please use one of these subcommands: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }
        guard let subcommand = subcommands[input] else {
            await output.append(errorText: "Subcommand `\(input)` not in the subcommands \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }
        guard let channelId = context.channel?.id, let channel = context.sink?.channel(for: channelId) else {
            await output.append(errorText: "No channel available")
            return
        }

        await subcommand(output, channel, context)
    }
}
