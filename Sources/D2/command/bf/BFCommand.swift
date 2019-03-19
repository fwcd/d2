import Sword
import Dispatch

// The first group matches the BF code
fileprivate let codePattern = try! Regex(from: "(?:`(?:``(?:\\w*\n)?)?)?([^`]+)`*")
fileprivate let maxExecutionSeconds = 3

class BFCommand: Command {
	let description = "Interprets BF code"
	var running = false
	
	func invoke(withMessage message: Message, args: String) {
		guard !running else {
			message.channel.send("Whoa, not so fast. Wait for the program to finish!")
			return
		}
		
		running = true
		
		let queue = DispatchQueue(label: "BF runner")
		var interpreter = BFInterpreter()
		
		let task = DispatchWorkItem {
			let response: String
			
			if let program = codePattern.firstGroups(in: args)?[1] {
				do {
					let output = try interpreter.interpret(program: program)
					
					response = "```\n\(output)\n```"
				} catch BFError.parenthesesMismatch(let msg) {
					response = "Parentheses mismatch error: `\(msg)`"
				} catch {
					response = "Error while executing code"
				}
			} else {
				response = "Syntax error"
			}
			
			if interpreter.cancelled {
				print("Cancelled BF task finished running")
				message.channel.send("Your program took longer than \(maxExecutionSeconds) seconds. The output was:\n\(response)")
			} else {
				print("BF task finished running")
				message.channel.send(response)
			}
		}
		
		queue.async(execute: task)
		_ = task.wait(timeout: DispatchTime.now() + .seconds(maxExecutionSeconds))
		interpreter.cancel()
		
		running = false
	}
}
