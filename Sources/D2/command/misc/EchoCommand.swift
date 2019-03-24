import SwiftDiscord
import Foundation
import Dispatch

fileprivate let argPattern = try! Regex(from: "(?:(\\d+)\\s*)?([\\s\\S]*)")

class EchoCommand: Command {
	let description = "Prints something n times"
	let requiredPermissionLevel = PermissionLevel.vip
	private let timer: RepeatingTimer
	
	init(intervalSeconds: Int = 1) {
		timer = RepeatingTimer(intervalSeconds: intervalSeconds)
	}
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		if let groups = argPattern.firstGroups(in: args) {
			// Extract parsed values
			let n = groups[safe: 1].flatMap { Int($0) } ?? 1
			guard let value = groups[safe: 2] else { return }
			
			timer.schedule(nTimes: n) { _, _ in
				output.append(value)
			}
		}
	}
}
