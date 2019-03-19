import Sword

class BFCommand: Command {
	let description = "Interprets BF code"
	
	func invoke(withMessage message: Message, args: String) {
		do {
			var interpreter = BFInterpreter()
			let output = try interpreter.interpret(program: args)
			
			message.channel.send("```\n\(output)\n```")
		} catch BFError.parenthesesMismatch(let msg) {
			message.channel.send("Parentheses mismatch error: `\(msg)`")
		} catch {
			message.channel.send("Error while executing code")
		}
	}
}
