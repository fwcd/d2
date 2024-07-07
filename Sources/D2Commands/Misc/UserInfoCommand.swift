import D2MessageIO
import Utils
import Foundation

public class UserInfoCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches a user's presence",
        longDescription: "Fetches information about a user's status and currently played game",
        requiredPermissionLevel: .basic,
        platformAvailability: ["Discord"]
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let guild = context.guild else {
            await output.append("Not on a guild.")
            return
        }
        guard let user = input.asMentions?.first ?? context.author else {
            await output.append("Please mention someone!")
            return
        }
        guard let member = guild.members[user.id] else {
            await output.append("Not a guild member.")
            return
        }
        let presence = guild.presences[user.id]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"

        await output.append(Embed(
            title: "\(user.username)#\(user.discriminator)",
            thumbnail: context.sink?.name == "Discord"
                ? URL(string: "https://cdn.discordapp.com/avatars/\(user.id)/\(user.avatar).png?size=128").map { Embed.Thumbnail(url: $0) }
                : nil,
            footer: "ID: \(user.id)",
            fields: [
                Embed.Field(name: "Nick", value: member.nick.map { "`\($0)`" } ?? "_none_"),
                Embed.Field(name: "Roles", value: guild.roles(for: member).sorted(by: descendingComparator { $0.position }).map { "`\($0.name)`" }.joined(separator: ", ").nilIfEmpty ?? "_none_"),
                Embed.Field(name: "Voice Status", value: ((member.deaf ? ["deaf"] : []) + (member.mute ? ["mute"] : [])).joined(separator: ", ").nilIfEmpty ?? "_none_"),
                Embed.Field(name: "Joined at", value: dateFormatter.string(from: member.joinedAt))
            ] + (presence.map { [
                Embed.Field(name: "Status", value: $0.status.map(stringOf(status:)) ?? "?")
            ] + $0.activities.map {
                let details: [(String, String?)] = [
                    ("Assets", $0.assets.flatMap { [$0.largeText, $0.smallText].compactMap { $0 }.joined(separator: ", ").nilIfEmpty }),
                    ("Details", $0.details),
                    ("Party", $0.party.map { "\($0.id ?? "?") - sizes: \($0.sizes ?? [])" }),
                    ("State", $0.state),
                    ("Type", stringOf(activityType: $0.type)),
                    ("Timestamps", "playing for \($0.timestamps?.interval?.displayString ?? "unknown amount of time")"),
                    ("URL", $0.url)
                ]
                return Embed.Field(name: "Activity: `\($0.name)`", value: details.compactMap { (k, v) in v.map { "\(k): \($0)" } }.joined(separator: "\n"))
            } } ?? [])
        ))
    }

    private func stringOf(status: Presence.Status) -> String {
        switch status {
            case .idle: return ":yellow_circle: Idle"
            case .online: return ":green_circle: Online"
            case .offline: return ":white_circle: Offline"
            case .doNotDisturb: return ":red_circle: Do not disturb"
            default: return ":question: Status \(status.rawValue)"
        }
    }

    private func stringOf(activityType: Presence.Activity.ActivityType) -> String {
        switch activityType {
            case .game: return ":video_game: Playing"
            case .listening: return ":musical_note: Listening"
            case .stream: return ":movie_camera: Streaming"
            default: return ":question: Activity type \(activityType.rawValue)"
        }
    }
}
