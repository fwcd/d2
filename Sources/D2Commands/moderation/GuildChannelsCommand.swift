import D2MessageIO
import Utils

public class GuildChannelsCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Fetches the channel list of a guild",
        requiredPermissionLevel: .admin
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let client = context.client else {
            output.append(errorText: "No client available!")
            return
        }

        let guildId: GuildID
        let useChannelLinks: Bool

        if input.isEmpty {
            guard let guild = context.guild else {
                output.append(errorText: "Not on a guild!")
                return
            }
            guildId = guild.id
            useChannelLinks = true
        } else {
            guildId = GuildID(input, clientName: client.name)
            useChannelLinks = false
        }

        guard let guild = client.guild(for: guildId) else {
            output.append(errorText: "No guild with this id found!")
            return
        }

        let uncategorized = "Uncategorized"
        var categories: [String: (Int, [Guild.Channel])] = [uncategorized: (-1, [])]

        for treeNode in guild.channelTree {
            let channel = treeNode.channel
            if channel.type == .category {
                categories[channel.name] = (channel.position, treeNode.traversed)
            } else {
                categories[uncategorized]!.1.append(channel)
            }
        }

        output.append(Embed(
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
                                switch $0.type {
                                    case .text: return useChannelLinks ? "<#\($0.id)>" : "#\($0.name)"
                                    case .voice: return ":speaker: \($0.name)"
                                    default: return nil
                                }
                            }
                            .joined(separator: "\n")
                            .nilIfEmpty ?? "_none_"
                    )
                }
        ))
    }
}
