import D2MessageIO
import D2Permissions
import D2Utils

public class CycleThroughCommand: StringCommand {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Animates a sequence of characters",
		longDescription: "Creates a pseudo-animation by repeatedly editing the sent Discord message",
		requiredPermissionLevel: .vip
	)
	private let loops = 4
	private let timer = RepeatingTimer(interval: .milliseconds(500))
	
	public init() {}
	
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
		let channelId = context.channel!.id
		
		client.sendMessage(Message(content: String(firstFrame)), to: channelId) { sentMessage, _ in
			self.timer.schedule(nTimes: self.loops * frames.count) { i, _ in
				let frame = String(frames[i % frames.count])
				client.editMessage(sentMessage!.id!, on: channelId, content: frame)
			}
		}
	}
}
