import D2MessageIO
import D2Permissions
import Foundation

public class StatsCommand: StringCommand {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Fetches server statistics",
		longDescription: "Outputs a range of interesting statistics about the current guild",
		requiredPermissionLevel: .basic
	)
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		output.append(Embed(
			title: ":chart_with_upwards_trend: Server Statistics",
			description: computeStats(context: context).map { "\($0.0): \($0.1)" }.joined(separator: "\n")
		))
	}
	
	private func computeStats(context: CommandContext) -> [(String, String)] {
		var memberCount: Int = 0
		var userCount: Int = 0
		var botCount: Int = 0
		var longestUsername: String = ""
		var mostRolesUsername: String = ""
		var mostRoles: [String] = []
		var voiceChannelCount: Int = 0
		var textChannelCount: Int = 0
		var presences: [Presence] = []
		var longestPlayTime: Int = 0
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
				if (member.roles?.count ?? -1) > mostRoles.count {
					mostRolesUsername = user.username
					// TODO: Proper roles API in MessageIO guild structures
					mostRoles = member.roles?.map { $0.name } ?? []
				}
			}
			
			for (_, channel) in guild.channels {
				if channel is GuildVoiceChannel {
					voiceChannelCount += 1
				} else {
					textChannelCount += 1
				}
			}
			
			for (_, presence) in guild.presences {
				presences.append(presence)
				if let game = presence.game {
					let playTime = (game.timestamps?.end ?? Int(Date().timeIntervalSince1970)) - (game.timestamps?.start ?? Int.max)
					if playTime > longestPlayTime {
						longestPlayTime = playTime
						longestPlayTimeGame = game.name
						longestPlayTimeUsername = presence.user.username
					}
				}
			}
		}
		
		let mostPlayed = Dictionary(grouping: presences.filter { $0.game != nil }, by: { $0.game?.name ?? "" })
			.max { $0.1.count < $1.1.count }
		
		return [
			(":tophat: Members", String(memberCount)),
			(":speaking_head: Users", String(userCount)),
			(":robot: Bots", String(botCount)),
			(":speaker: Voice Channels", String(voiceChannelCount)),
			(":pencil2: Text Channels", String(textChannelCount)),
			(":straight_ruler: Longest Username", "`\(longestUsername)`"),
			(":triangular_flag_on_post: Most Roles", "\(mostRoles.joined(separator: ", ")) by `\(mostRolesUsername)`"),
			(":stopwatch: Longest Play Time", "`\(longestPlayTimeUsername)` playing \(longestPlayTimeGame) for \(longestPlayTime)s"),
			(":video_game: Currently Most Played Game", "\(mostPlayed?.0 ?? "None") by \(mostPlayed?.1.count ?? 0) players")
		]
	}
}
