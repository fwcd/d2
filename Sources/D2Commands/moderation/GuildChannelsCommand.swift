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

        if input.isEmpty {
            guard let guild = context.guild else {
                output.append(errorText: "Not on a guild!")
                return
            }
            guildId = guild.id
        } else {
            guildId = GuildID(input, clientName: client.name)
        }

        guard let guild = client.guild(for: guildId) else {
            output.append(errorText: "No guild with this id found!")
            return
        }

        let uncategorized = "Uncategorized"
        var categories: [String: [Guild.Channel]] = [uncategorized: []]

        for treeNode in guild.channelTree {
            let channel = treeNode.channel
            if channel.type == .category {
                categories[channel.name] = treeNode.traversed
            } else {
                categories[uncategorized]!.append(channel)
            }
        }

        output.append(Embed(
            title: ":accordion: Channels on `\(guild.name)`",
            fields: categories
                .filter { !$0.value.isEmpty }
                .map { (category, channels) in
                    Embed.Field(
                        name: "▾ \(category)",
                        value: channels
                            .compactMap {
                                switch $0.type {
                                    case .text: return "#\($0.name)"
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
