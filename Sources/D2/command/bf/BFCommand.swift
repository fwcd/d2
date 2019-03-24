import SwiftDiscord
import Dispatch

fileprivate let maxExecutionSeconds = 3

class BFCommand: StringCommand {
	let description = "Interprets BF code"
	let requiredPermissionLevel = PermissionLevel.basic
	private var running = false
	
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard !running else {
			output.append("Whoa, not so fast. Wait for the program to finish!")
			return
		}
		
		running = true
		
		let queue = DispatchQueue(label: "BF runner")
		var interpreter = BFInterpreter()
		
		let task = DispatchWorkItem {
			var response: String
			
			if let program = bfCodePattern.firstGroups(in: input)?[1] {
				do {
					let output = try interpreter.interpret(program: program)
					
					response = "```\n\(output.content)\n```"
					if output.tooLong {
						response += "\nYour program's output was too long to display!"
					}
				} catch BFError.parenthesesMismatch(let msg) {
					response = "Parentheses mismatch error: `\(msg)`"
				} catch BFError.multiplicationOverflow(let a, let b) {
					response = "Overflow while multiplying \(a) with \(b)"
				} catch BFError.incrementOverflow(let x) {
					response = "Overflow while incrementing \(x)"
				} catch BFError.decrementOverflow(let x) {
					response = "Overflow while decrementing \(x)"
				} catch BFError.addressOverflow(let address) {
					response = "Overflow while dereferencing address \(address)"
				} catch {
					response = "Error while executing code"
				}
			} else {
				response = "Syntax error"
			}
			
			if interpreter.cancelled {
				print("Cancelled BF task finished running")
				output.append("Your program took longer than \(maxExecutionSeconds) seconds. The output was:\n\(response)")
			} else {
				print("BF task finished running")
				output.append(response)
			}
		}
		
		let timeout = DispatchTime.now() + .seconds(maxExecutionSeconds)
		queue.async(execute: task)
		
		DispatchQueue.global(qos: .userInitiated).async {
			_ = task.wait(timeout: timeout)
			interpreter.cancel()
			self.running = false
		}
	}
}
