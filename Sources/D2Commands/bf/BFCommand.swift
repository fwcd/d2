import D2MessageIO
import Logging
import D2Permissions
import D2Utils
import Dispatch

fileprivate let log = Logger(label: "D2Commands.BFCommand")

public class BFCommand: StringCommand {
	public let info = CommandInfo(
		category: .bf,
		shortDescription: "Interprets BF code",
		longDescription: "Asynchronously invokes a Brainf&*k interpreter",
		requiredPermissionLevel: .basic
	)
	private let maxExecutionSeconds: Int
	@Synchronized private var running = false
	
	public init(maxExecutionSeconds: Int = 3) {
		self.maxExecutionSeconds = maxExecutionSeconds
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard !running else {
			output.append(errorText: "Whoa, not so fast. Wait for the program to finish!")
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
				log.debug("Cancelled BF task finished running")
				output.append(errorText: "Your program took longer than \(self.maxExecutionSeconds) seconds. The output was:\n\(response)")
			} else {
				log.debug("BF task finished running")
				output.append(response)
			}
		}
		queue.async(execute: task)
		
		let timeout = DispatchTime.now() + .seconds(maxExecutionSeconds)
		DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: timeout) {
			interpreter.cancel()
			self.running = false
		}
	}
}
