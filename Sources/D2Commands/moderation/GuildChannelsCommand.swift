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

        output.append(Embed(
            title: ":accordion: Channels on `\(guild.name)`",
            description: guild.channelsInOrder
                .map {
                    switch $0.type {
                        case .text: return "#\($0.name)"
                        case .voice: return ":speaker: \($0.name)"
                        case .category: return "**▾ \($0.name)**"
                    }
                }
                .joined(separator: "\n")
        ))
    }
}
