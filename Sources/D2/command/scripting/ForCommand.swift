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
	
	func invoke(withMessage message: DiscordMessage, context: CommandContext, args: String) {
		if let parsedArgs = argsPattern.firstGroups(in: args) {
			let loopVariable = parsedArgs[1]
			let rawRange = parsedArgs[2]
			let rawCode = parsedArgs[3]
			let loopVariablePattern = try! Regex(from: "\\b\(Regex.escape(loopVariable))\\b")
			
			if let range = parseIntRange(from: rawRange) {
				schedule(
					nTimes: range.count,
					lowerBound: range.lowerBound,
					loopVariablePattern: loopVariablePattern,
					rawCode: rawCode,
					message: message,
					context: context
				)
			} else if let closedRange = parseClosedIntRange(from: rawRange) {
				schedule(
					nTimes: closedRange.count,
					lowerBound: closedRange.lowerBound,
					loopVariablePattern: loopVariablePattern,
					rawCode: rawCode,
					message: message,
					context: context
				)
			}
		} else {
			message.channel?.send("Syntax error: For arguments need to match `\(argsPattern.rawPattern)`")
		}
	}
	
	private func schedule(nTimes n: Int, lowerBound: Int, loopVariablePattern: Regex, rawCode: String, message: DiscordMessage, context: CommandContext) {
		timer.schedule(nTimes: n) { i, timerCtx in
			let iInRange = lowerBound + i
			let code = loopVariablePattern.replace(in: rawCode, with: String(iInRange))
			
			if let parsedCommand = innerCommandPattern.firstGroups(in: code) {
				let commandName = parsedCommand[1]
				let commandArgs = parsedCommand[2]
				
				if let subcommand = context.registry[commandName] {
					subcommand.invoke(withMessage: message, context: context, args: commandArgs)
				} else {
					message.channel?.send("Unknown subcommand `\(commandName)`")
					timerCtx.cancel()
				}
			} else {
				message.channel?.send("Inner syntax error: `\(code)` could not be parsed as a command invocation")
			}
		}
	}
}
