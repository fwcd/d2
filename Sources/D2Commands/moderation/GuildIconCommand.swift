import D2MessageIO
import Utils
import Graphics

public class GuildIconCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Fetches a guild's icon",
        requiredPermissionLevel: .basic,
        platformAvailability: ["Discord"]
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Not on a guild!")
            return
        }
        guard let icon = guild.icon else {
            output.append(errorText: "Guild has no icon")
            return
        }

        // TODO: GIF icons
        // TODO: Move guild icon URL logic into message clients, similar to how
        //       this is handled with user avatars.
        Promise.catching { try HTTPRequest(host: "cdn.discordapp.com", path: "/icons/\(guild.id)/\(icon).png") }
            .then { $0.runAsync() }
            .mapCatching { try Image(fromPng: $0) }
            .listen {
                do {
                    try output.append($0.get())
                } catch {
                    output.append(error, errorText: "Could not fetch guild icon.")
                }
            }
    }
}
