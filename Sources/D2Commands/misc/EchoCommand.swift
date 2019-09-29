import SwiftDiscord
import D2Permissions
import Foundation
import Dispatch
import D2Utils

fileprivate let argPattern = try! Regex(from: "(?:(\\d+)\\s*)?([\\s\\S]*)")

public class EchoCommand: Command {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Outputs something n times",
		longDescription: "Outputs the given input n times with an interval of 1 second by default",
		requiredPermissionLevel: .vip
	)
	public let inputValueType = .any
	public let outputValueType = .any
	private let timer: RepeatingTimer
	
	public init(intervalSeconds: Int = 1) {
		timer = RepeatingTimer(interval: .seconds(intervalSeconds))
	}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		if let groups = argPattern.firstGroups(in: input.asText ?? "") {
			// Extract parsed values
			let n = groups[safely: 1].flatMap { Int($0) } ?? 1
			let value = groups[safely: 2]?.nilIfEmpty.map { .text($0) } ?? input
			
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
	
	private func append(_ value: RichValue, to output: CommandOutput) {
		let lengthLimit = output.messageLengthLimit ?? Int.max
		
		if (value.asText?.count ?? 0) > lengthLimit {
			output.append("Can not echo value that is longer than \(lengthLimit) characters")
		} else {
			output.append(value)
		}
	}
}
