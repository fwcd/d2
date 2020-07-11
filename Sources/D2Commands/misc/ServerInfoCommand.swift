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
            thumbnail: URL(string: "https://cdn.discordapp.com/icons/\(guild.id)/\(guild.icon).png").map(Embed.Thumbnail.init(url:)),
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
        
        for (_, presence) in guild.presences {
            presences.append(presence)
            if let game = presence.game, let playTime = game.timestamps?.interval, playTime > longestPlayTime {
                longestPlayTime = playTime
                longestPlayTimeGame = game.name
                longestPlayTimeUsername = presence.user.username
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"

        let mostPlayed = Dictionary(grouping: presences.filter { $0.game != nil }, by: { $0.game?.name ?? "" })
            .max { $0.1.count < $1.1.count }

        let longestMessage = try! messageDB.prepare("""
            select content, user_name
            from messages natural join channels
                                  join users on (author_id == user_id)
            where guild_id == ?
            order by length(content) desc
            limit 1
            """, "\(guild.id)")
                .makeIterator().next()
                .map { "`\(($0[0] as! String).truncate(100, appending: "..."))` by `\($0[1] as! String)`" }

        return [
            (":island: General", [
                ("Owner", guild.members[guild.id]?.displayName ?? "?"),
                ("Region", guild.region),
                ("Created at", dateFormatter.string(from: guild.joinedAt)),
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
                ("Most Roles", "\(mostRoles.map { "`\($0)`" }.joined(separator: ", ")) by `\(mostRolesUsername)`"),
                ("Longest Play Time", "`\(longestPlayTimeUsername)` playing \(longestPlayTimeGame) for \(longestPlayTime.displayString)"),
                ("Currently Most Played Game", "\(mostPlayed?.0 ?? "None") by \(mostPlayed?.1.count ?? 0) \("player".pluralize(with: mostPlayed?.1.count ?? 0))")
            ]),
            (":incoming_envelope: Messages", [
                ("Longest Message", longestMessage)
            ])
        ]
    }
}
