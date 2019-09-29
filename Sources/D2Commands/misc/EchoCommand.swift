import SwiftDiscord
import D2Permissions
import Foundation
import Dispatch
import D2Utils

fileprivate let argPattern = try! Regex(from: "(?:(\\d+)\\s*)?([\\s\\S]*)")

public class EchoCommand: Command {
	public let description = "Prints something n times"
	public let inputValueType: RichValueType = .any
	public let outputValueType: RichValueType = .any
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
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
