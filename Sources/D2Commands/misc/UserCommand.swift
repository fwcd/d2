import SwiftDiscord
import Foundation

public class UserCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches a user's presence",
        longDescription: "Fetches information about a user's status and currently played game",
        requiredPermissionLevel: .vip
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append("Not on a guild.")
            return
        }
        guard let user = context.message.mentions.first else {
            output.append("Please mention someone!")
            return
        }
        guard let member = guild.members[user.id] else {
            output.append("Not a guild member.")
            return
        }
        let presence = guild.presences[user.id]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"

        output.append(DiscordEmbed(
            title: "\(user.username)#\(user.discriminator)",
            thumbnail: URL(string: "https://cdn.discordapp.com/avatars/\(user.id)/\(user.avatar).png?size=128").map { DiscordEmbed.Thumbnail(url: $0) },
            footer: DiscordEmbed.Footer(text: "ID: \(user.id)"),
            fields: [
                DiscordEmbed.Field(name: "Nick", value: member.nick ?? "_none_"),
                DiscordEmbed.Field(name: "Roles", value: member.roles?.map { $0.name }.joined(separator: "\n").nilIfEmpty ?? "_none_"),
                DiscordEmbed.Field(name: "Voice Status", value: ((member.deaf ? ["deaf"] : []) + (member.mute ? ["mute"] : [])).joined(separator: ", ").nilIfEmpty ?? "_none_"),
                DiscordEmbed.Field(name: "Joined at", value: dateFormatter.string(from: member.joinedAt))
            ] + (presence.map { [
                DiscordEmbed.Field(name: "Status", value: stringOf(status: $0.status))
            ] + ($0.game.map { [
                DiscordEmbed.Field(name: "Activity", value: """
                    Name: \($0.name)
                    Assets: \($0.assets.flatMap { [$0.largeText, $0.smallText].compactMap { $0 }.joined(separator: ", ").nilIfEmpty } ?? "_none_")
                    Details: \($0.details ?? "_none_")
                    Party: \($0.party.map { "\($0.id) - sizes: \($0.sizes ?? [])" } ?? "_none_")
                    State: \($0.state ?? "_none_")
                    Type: \(stringOf(activityType: $0.type))
                    Timestamps: \($0.timestamps.map { "start: \($0.start ?? 0) - end: \($0.end ?? 0)" } ?? "_none_")
                    """)
            ] } ?? []) } ?? [])
        ))
    }
    
    private func stringOf(status: DiscordPresenceStatus) -> String {
        switch status {
            case .idle: return ":yellow_circle: Idle"
            case .online: return ":green_circle: Online"
            case .offline: return ":white_circle: Offline"
            case .doNotDisturb: return ":red_circle: Do not disturb"
        }
    }
    
    private func stringOf(activityType: DiscordActivityType) -> String {
        switch activityType {
            case .game: return ":video_game: Playing"
            case .listening: return ":musical_note: Listening"
            case .stream: return ":movie_camera: Streaming"
        }
    }
}
