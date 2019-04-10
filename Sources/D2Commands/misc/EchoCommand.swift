import SwiftDiscord
import D2Permissions
import Foundation
import Dispatch
import D2Utils

fileprivate let argPattern = try! Regex(from: "(?:(\\d+)\\s*)?([\\s\\S]*)")

public class EchoCommand: Command {
	public let description = "Prints something n times"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
	private let timer: RepeatingTimer
	
	public init(intervalSeconds: Int = 1) {
		timer = RepeatingTimer(interval: .seconds(intervalSeconds))
	}
	
	public func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		if let groups = argPattern.firstGroups(in: args) {
			// Extract parsed values
			let n = groups[safely: 1].flatMap { Int($0) } ?? 1
			guard let value = (groups[safely: 2]?.nilIfEmpty.map { DiscordMessage(content: $0) } ?? input) else { return }
			
			if n == 1 {
				// Output synchronously
				append(value, to: output)
			} else {
				guard !timer.isRunning else {
					output.append("Cannot run multiple asynchronous `echo`s concurrently")
					return
				}
				
				timer.schedule(nTimes: n) { _, _ in
					self.append(value, to: output)
				}
			}
		}
	}
	
	private func append(_ msg: DiscordMessage, to output: CommandOutput) {
		let lengthLimit = output.messageLengthLimit ?? 0
		
		if msg.content.count > lengthLimit {
			output.append("Can not echo message that is longer than \(lengthLimit) characters")
		} else {
			output.append(msg)
		}
	}
}
