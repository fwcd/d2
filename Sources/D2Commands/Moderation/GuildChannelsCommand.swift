import D2MessageIO
import Utils

public class GuildChannelsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Fetches the channel list of a guild",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let sink = context.sink else {
            await output.append(errorText: "No client available!")
            return
        }

        let guildId: GuildID
        let useChannelLinks: Bool

        if input.isEmpty {
            guard let guild = context.guild else {
                await output.append(errorText: "Not on a guild!")
                return
            }
            guildId = guild.id
            useChannelLinks = true
        } else {
            guildId = GuildID(input, clientName: sink.name)
            useChannelLinks = false
        }

        guard let guild = await sink.guild(for: guildId) else {
            await output.append(errorText: "No guild with this id found!")
            return
        }

        let uncategorized = "Uncategorized"
        var categories: [String: (Int, [(channel: Channel, depth: Int)])] = [uncategorized: (-1, [])]

        for treeNode in guild.channelTree {
            let channel = treeNode.channel
            if channel.type == .category {
                categories[channel.name] = (channel.position, treeNode.traversedWithDepth())
            } else {
                categories[uncategorized]!.1.append((channel: channel, depth: 0))
            }
        }

        await output.append(Embed(
            title: ":accordion: Channels on `\(guild.name)`",
            fields: categories
                .sorted(by: ascendingComparator(comparing: \.value.0))
                .map { ($0.0, $0.1.1) }
                .filter { !$0.1.isEmpty }
                .map { (category, channels) in
                    Embed.Field(
                        name: "▾ \(category)",
                        value: channels
                            .compactMap {
                                let label: String
                                let link = "\(useChannelLinks ? "<#\($0.channel.id)>" : "#\($0.channel.name)") (\($0.channel.id))"
                                switch $0.channel.type {
                                    case .voice: label = ":speaker: \($0.channel.name) (\($0.channel.id))"
                                    case .publicThread, .privateThread, .newsThread: label = ":thread: \(link)"
                                    default: label = link
                                }
                                // We deliberately use another blank Unicode character instead of a space here
                                // since Discord trims the embed's lines.
                                return String(repeating: "⠀", count: $0.depth) + label
                            }
                            .joined(separator: "\n")
                            .nilIfEmpty ?? "_none_"
                    )
                }
        ))
    }
}
