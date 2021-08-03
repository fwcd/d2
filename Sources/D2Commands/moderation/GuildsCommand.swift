import D2MessageIO
import Utils

public class GuildsCommand: VoidCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Fetches a list of guilds this bot is on",
        requiredPermissionLevel: .admin
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(output: CommandOutput, context: CommandContext) {
        guard let guilds = context.client?.guilds else {
            output.append(errorText: "Could not fetch guilds")
            return
        }

        output.append(Embed(
            title: ":accordion: Guilds",
            fields: guilds.sorted(by: descendingComparator { $0.members.count }).map { guild in
                Embed.Field(
                    name: guild.name,
                    value: [
                        guild.ownerId.flatMap { guild.members[$0].map { "owned by `\($0.user.username)#\($0.user.discriminator)` (<@\($0.user.id)>)" } },
                        "\(guild.members.count) \("member".pluralized(with: guild.members.count))",
                        "\(guild.channels.count) \("channel".pluralized(with: guild.channels.count))",
                        "\(guild.id)"
                    ].compactMap { $0 }.joined(separator: "\n"),
                    inline: true
                )
            }
        ))
    }
}
