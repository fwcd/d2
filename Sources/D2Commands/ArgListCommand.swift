import SwiftDiscord
import D2Permissions

/**
 * A command that takes input in the form of whitespace-separated
 * arguments with a fixed number of arguments. Missing direct arguments
 * (those provided in the "args" parameter) are substituted with the input.
 * 
 * This conveniently enables partial application in command execution pipes.
 */
public protocol ArgListCommand: Command {
	var expectedArgCount: Int { get }
	
	func invoke(withInputArgs inputArgs: [String], output: CommandOutput, context: CommandContext)
}

extension ArgListCommand {
	public var inputValueType: String { return "text" }
	
	public func invoke(withArgs args: String, input: RichValue, output: CommandOutput, context: CommandContext) {
		let splitArgs = args.split(separator: " ")
			.prefix(expectedArgCount)
			.map { String($0) }
		
		if splitArgs.count == expectedArgCount {
			// Skip input splitting if there are already enough arguments provided directly
			invoke(withInputArgs: splitArgs, output: output, context: context)
		} else {
			let splitInputs = (input.asText ?? "")
				.split(separator: " ")
				.prefix(expectedArgCount - splitArgs.count)
				.map { String($0) }
			let totalArgs = splitArgs + splitInputs
			
			if totalArgs.count < expectedArgCount {
				output.append("`\(self)` received too few arguments: Expected \(expectedArgCount), but got only \(totalArgs.count)")
			} else {
				invoke(withInputArgs: totalArgs, output: output, context: context)
			}
		}
	}
}
