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
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		output.append(Embed(
			title: ":chart_with_upwards_trend: Server Statistics",
			fields: computeStats(context: context)
				.map { Embed.Field(name: $0.0, value: $0.1.map { "\($0.0): \($0.1)" }.joined(separator: "\n")) }
		))
	}
	
	private func computeStats(context: CommandContext) -> [String: [(String, String)]] {
		var memberCount: Int = 0
		var userCount: Int = 0
		var botCount: Int = 0
		var longestUsername: String = ""
		var mostRolesUsername: String = ""
		var mostRoles: [String] = []
		var voiceChannelCount: Int = 0
		var textChannelCount: Int = 0
		var presences: [Presence] = []
		var longestPlayTime: TimeInterval = 0
		var longestPlayTimeGame: String = ""
		var longestPlayTimeUsername: String = ""
		
		if let guild = context.guild {
			for (_, member) in guild.members {
				memberCount += 1
				let user = member.user
				if user.bot {
					botCount += 1
				} else {
					userCount += 1
				}
				if user.username.count > longestUsername.count {
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
		}
		
		let mostPlayed = Dictionary(grouping: presences.filter { $0.game != nil }, by: { $0.game?.name ?? "" })
			.max { $0.1.count < $1.1.count }
		
		return [
			":tophat: Counts": [
				("Members", String(memberCount)),
				("Users", String(userCount)),
				("Bots", String(botCount)),
				("Voice Channels", String(voiceChannelCount)),
				("Text Channels", String(textChannelCount)),
			],
			":triangular_flag_on_post: Highscores": [
				("Longest Username", "`\(longestUsername)`"),
				("Most Roles", "\(mostRoles.map { "`\($0)`" }.joined(separator: ", ")) by `\(mostRolesUsername)`"),
				("Longest Play Time", "`\(longestPlayTimeUsername)` playing \(longestPlayTimeGame) for \(longestPlayTime.displayString)"),
				("Currently Most Played Game", "\(mostPlayed?.0 ?? "None") by \(mostPlayed?.1.count ?? 0) players")
			]
		]
	}
}
