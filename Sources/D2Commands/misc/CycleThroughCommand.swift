import SwiftDiscord
import D2Permissions
import D2Utils

class CycleThroughCommand: StringCommand {
	public let description = "Animates a sequence of characters"
	let requiredPermissionLevel = PermissionLevel.vip
	private let loops = 4
	private let timer = RepeatingTimer(interval: .milliseconds(500))
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard !timer.isRunning else {
			output.append("Animation is already running.")
			return
		}
		
		let frames = input.split(separator: " ")
		
		guard frames.count < 4 else {
			output.append("Too many frames.")
			return
		}
		
		guard let firstFrame = frames.first else {
			output.append("Cannot create empty animation.")
			return
		}
		
		let client = context.client!
		let channelID = context.channel!.id
		
		client.sendMessage(DiscordMessage(content: String(firstFrame)), to: channelID) { sentMessage, _ in
			self.timer.schedule(nTimes: self.loops * frames.count) { i, _ in
				let frame = String(frames[i % frames.count])
				client.editMessage(sentMessage!.id, on: channelID, content: frame)
			}
		}
	}
}
