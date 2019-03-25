import SwiftDiscord

fileprivate let rawRangePattern = "\\d+\\.\\.[\\.<]\\d+"

// Matches the arguments, capturing the range
fileprivate let inputPattern = try! Regex(from: "^(\(rawRangePattern))")

class ForCommand: StringCommand {
	let description = "Iterates through a range and prints the loop indices."
	let requiredPermissionLevel = PermissionLevel.vip
	private let timer: RepeatingTimer
	
	init(intervalSeconds: Int = 1) {
		timer = RepeatingTimer(intervalSeconds: intervalSeconds)
	}
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let parsedArgs = inputPattern.firstGroups(in: input) else {
			output.append("Syntax error: For arguments need to match `[number](...|..<)[number]`")
			return
		}
		
		let rawRange = parsedArgs[1]
		
		if let range: LowBoundedIntRange = parseIntRange(from: rawRange) ?? parseClosedIntRange(from: rawRange) {
			if range.count < 4 {
				schedule(forEachIn: range, output: output)
			} else {
				output.append("Your range is too long!")
			}
		}
	}
	
	private func schedule(forEachIn range: LowBoundedIntRange, output: CommandOutput) {
		timer.schedule(nTimes: range.count) { i, _ in
			output.append(String(range.lowerBound + i))
		}
	}
}
