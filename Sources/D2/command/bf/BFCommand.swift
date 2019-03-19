import Sword

// The first group matches the BF code
fileprivate let codePattern = try! Regex(from: "(?:`(?:``(?:\\w*\n)?)?)?([^`]+)`*")

class BFCommand: Command {
	let description = "Interprets BF code"
	
	func invoke(withMessage message: Message, args: String) {
		if let program = codePattern.firstGroups(in: args)?[1] {
			do {
				var interpreter = BFInterpreter()
				let output = try interpreter.interpret(program: program)
				
				message.channel.send("```\n\(output)\n```")
			} catch BFError.parenthesesMismatch(let msg) {
				message.channel.send("Parentheses mismatch error: `\(msg)`")
			} catch {
				message.channel.send("Error while executing code")
			}
		} else {
			message.channel.send("Syntax error")
		}
	}
}
