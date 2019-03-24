import SwiftDiscord

fileprivate let innerCommandPattern = try! Regex(from: "(\\w+)\\s+(.+)")
fileprivate let rawRangePattern = "\\d+\\.\\.[\\.<]\\d+"

// Matches the arguments, capturing:
// 1: The loop variable
// 2: The range
// 3: The raw command to be executed
fileprivate let argsPattern = try! Regex(from: "^(\\w+)\\s+in\\s+(\(rawRangePattern))\\s+(.+)")

class ForCommand: Command {
	let description = "Iterates through a range"
	let requiredPermissionLevel = PermissionLevel.vip
	private let timer: RepeatingTimer
	
	init(intervalSeconds: Int = 1) {
		timer = RepeatingTimer(intervalSeconds: intervalSeconds)
	}
	
	func invoke(withInput input: DiscordMessage?, output: CommandOutput, context: CommandContext, args: String) {
		if let parsedArgs = argsPattern.firstGroups(in: args) {
			let loopVariable = parsedArgs[1]
			let rawRange = parsedArgs[2]
			let rawCode = parsedArgs[3]
			let loopVariablePattern = try! Regex(from: "\\b\(Regex.escape(loopVariable))\\b")
			
			if let range: LowBoundedIntRange = parseIntRange(from: rawRange) ?? parseClosedIntRange(from: rawRange) {
				schedule(forEachIn: range, withPattern: loopVariablePattern, rawCode: rawCode, input: input, output: output, context: context)
			}
		} else {
			output.append("Syntax error: For arguments need to match `[variable] in [number](...|..<)[number] [command invocation]`")
		}
	}
	
	private func schedule(forEachIn range: LowBoundedIntRange, withPattern loopVariablePattern: Regex, rawCode: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		timer.schedule(nTimes: range.count) { i, timerCtx in
			let iInRange = range.lowerBound + i
			let code = loopVariablePattern.replace(in: rawCode, with: String(iInRange))
			
			if let parsedCommand = innerCommandPattern.firstGroups(in: code) {
				let commandName = parsedCommand[1]
				let commandArgs = parsedCommand[2]
				
				if let subcommand = context.registry[commandName] {
					subcommand.invoke(withInput: input, output: output, context: context, args: commandArgs)
				} else {
					output.append("Unknown subcommand `\(commandName)`")
					timerCtx.cancel()
				}
			} else {
				output.append("Inner syntax error: `\(code)` could not be parsed as a command invocation")
			}
		}
	}
}
