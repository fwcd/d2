import D2MessageIO
import D2Permissions
import D2Utils
import Foundation

public class ServerInfoCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches statistics about the current server/guild",
        longDescription: "Outputs a range of interesting statistics about the current guild",
        requiredPermissionLevel: .basic
    )
    private let messageDB: MessageDatabase
    
    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let guild = context.guild else {
            output.append(errorText: "Could not compute statistics. Make sure that you are on a guild!")
            return
        }

        output.append(Embed(
            title: ":chart_with_upwards_trend: Server Statistics for `\(guild.name)`",
            thumbnail: context.client?.name == "Discord"
                ? URL(string: "https://cdn.discordapp.com/icons/\(guild.id)/\(guild.icon).png").map(Embed.Thumbnail.init(url:))
                : nil,
            fields: computeStats(for: guild)
                .map { Embed.Field(name: $0.0, value: $0.1
                    .compactMap { (k, v) in v.map { "\(k): \($0)" } }
                    .joined(separator: "\n")
                    .nilIfEmpty
                    ?? "_none_", inline: false) }
        ))
    }

    private func computeStats(for guild: Guild) -> [(String, [(String, String?)])] {
        var memberCount: Int = 0
        var userCount: Int = 0
        var botCount: Int = 0
        var longestUsername: String? = nil
        var mostRolesUsername: String = "?"
        var mostRoles: [String] = []
        var voiceChannelCount: Int = 0
        var textChannelCount: Int = 0
        var presences: [Presence] = []
        var longestPlayTime: TimeInterval = 0
        var longestPlayTimeGame: String = "?"
        var longestPlayTimeUsername: String = "?"
        
        for (_, member) in guild.members {
            memberCount += 1
            let user = member.user
            if user.bot {
                botCount += 1
            } else {
                userCount += 1
            }
            if user.username.count > (longestUsername?.count ?? 0) {
                longestUsername = user.username
            }
            if member.roleIds.count > mostRoles.count {
                mostRolesUsername = user.username
                // TODO: Proper roles API in MessageIO guild structures
                mostRoles = member.roleIds.compactMap { guild.roles[$0]?.name }
            }
        }
        
        for (_, channel) in guild.channels {
            if channel.isVoiceChannel {
                voiceChannelCount += 1
            } else {
                textChannelCount += 1
            }
        }
        
        for (id, presence) in guild.presences {
            presences.append(presence)
            if let game = presence.game, let playTime = game.timestamps?.interval, playTime > longestPlayTime {
                longestPlayTime = playTime
                longestPlayTimeGame = game.name
                longestPlayTimeUsername = guild.members[id]?.displayName ?? "?"
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"

        let mostPlayed = Dictionary(grouping: presences.filter { $0.game != nil }, by: { $0.game?.name ?? "" })
            .max { $0.1.count < $1.1.count }

        let longestMessage = try? messageDB.prepare("""
            select content, user_name
            from messages natural join channels
                                  join users on (author_id == user_id)
            where guild_id == ?
            order by length(content) desc
            limit 1
            """, "\(guild.id)")
                .makeIterator().next()
                .map { "`\(($0[0] as? String)?.truncate(80, appending: "...") ?? "?")` by `\(($0[1] as? String) ?? "?")`" }

        let mostMessagedChannel = try? messageDB.prepare("""
            select count(message_id), channel_name
            from channels natural join messages
            where guild_id == ?
            group by channel_id
            order by count(message_id) desc
            limit 1
            """, "\(guild.id)")
                .makeIterator().next()
                .map { "\(($0[0] as? Int64) ?? 0) messages on channel `\(($0[1] as? String) ?? "?")`" }
        
        let mostMessagesSent = try? messageDB.prepare("""
            select count(message_id), user_name
            from messages natural join channels
                                  join users on (user_id == author_id)
            where channels.guild_id == ?
            group by user_id
            order by count(message_id) desc
            limit 1
            """, "\(guild.id)")
                .makeIterator().next()
                .map { "\(($0[0] as? Int64) ?? 0) messages by `\(($0[1] as? String) ?? "?")`" }
        
        let mostActiveDay = try? messageDB.prepare("""
            select count(message_id), strftime("%Y-%m-%d", timestamp) as day
            from messages natural join channels
            where guild_id == ?
            group by day
            order by count(message_id) desc
            limit 1
            """, "\(guild.id)")
                .makeIterator().next()
                .map { "\(($0[0] as? Int64) ?? 0) messages on \(($0[1] as? String) ?? "?")" }

        return [
            (":island: General", [
                ("Owner", guild.members[guild.ownerId]?.displayName ?? "?"),
                ("Region", guild.region),
                ("Created at", (guild.members[guild.ownerId]?.joinedAt).map(dateFormatter.string(from:))),
                ("MFA Level", String(guild.mfaLevel)),
                ("Verification Level", String(guild.verificationLevel)),
                ("ID", "\(guild.id)")
            ]),
            (":tophat: Counts", [
                ("Members", String(memberCount)),
                ("Users", String(userCount)),
                ("Bots", String(botCount)),
                ("Voice Channels", String(voiceChannelCount)),
                ("Text Channels", String(textChannelCount)),
            ]),
            (":triangular_flag_on_post: Highscores", [
                ("Longest Username", longestUsername),
                ("Most Roles", "\(mostRoles.count) \("role".pluralize(with: mostRoles.count)) by `\(mostRolesUsername)`"),
                ("Longest Play Time", "`\(longestPlayTimeUsername)` playing \(longestPlayTimeGame) for \(longestPlayTime.displayString)"),
                ("Currently Most Played Game", "\(mostPlayed?.0 ?? "None") by \(mostPlayed?.1.count ?? 0) \("player".pluralize(with: mostPlayed?.1.count ?? 0))")
            ]),
            (":incoming_envelope: Messages", [
                ("Longest Message", longestMessage),
                ("Most Messaged Channel", mostMessagedChannel),
                ("Most Messages Sent", mostMessagesSent),
                ("Most Active Day", mostActiveDay)
            ])
        ]
    }
}
