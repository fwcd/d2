import SwiftDiscord
import D2Permissions
import Foundation
import Dispatch
import D2Utils

fileprivate let argPattern = try! Regex(from: "(?:(\\d+)\\s*)?([\\s\\S]*)")

class EchoCommand: Command {
	public let description = "Prints something n times"
	public let requiredPermissionLevel = PermissionLevel.vip
	private let timer: RepeatingTimer
	
	init(intervalSeconds: Int = 1) {
		timer = RepeatingTimer(interval: .seconds(intervalSeconds))
	}
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		if let groups = argPattern.firstGroups(in: args) {
			// Extract parsed values
			let n = groups[safely: 1].flatMap { Int($0) } ?? 1
			guard let value = (groups[safely: 2]?.nilIfEmpty.map { DiscordMessage(content: $0) } ?? input) else { return }
			
			if n == 1 {
				// Output synchronously
				output.append(value)
			} else {
				guard !timer.isRunning else {
					output.append("Cannot run multiple asynchronous `echo`s concurrently")
					return
				}
				
				timer.schedule(nTimes: n) { _, _ in
					output.append(value)
				}
			}
		}
	}
}
