import D2MessageIO
import Utils
import CairoGraphics

public class GuildIconCommand: StringCommand {
    public let info = CommandInfo(
        category: .moderation,
        shortDescription: "Fetches a guild's icon",
        requiredPermissionLevel: .basic,
        platformAvailability: ["Discord"]
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let guild = context.guild else {
            await output.append(errorText: "Not on a guild!")
            return
        }
        guard let icon = guild.icon else {
            await output.append(errorText: "Guild has no icon")
            return
        }

        // TODO: GIF icons
        // TODO: Move guild icon URL logic into message clients, similar to how
        //       this is handled with user avatars.
        do {
            let request = try HTTPRequest(host: "cdn.discordapp.com", path: "/icons/\(guild.id)/\(icon).png")
            let image = try await request.fetchPNG()
            try await output.append(image)
        } catch {
            await output.append(error, errorText: "Could not fetch guild icon.")
        }
    }
}
