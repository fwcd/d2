import SwiftDiscord

class BinaryIntOperationCommand: ArgListCommand {
	let name: String
	let description: String
	let requiredPermissionLevel = PermissionLevel.basic
	let expectedArgCount: Int = 2
	
	private let operation: (Int, Int) -> Int
	
	init(name: String, operation: @escaping (Int, Int) -> Int) {
		self.name = name
		self.operation = operation
		description = "Performs the binary int operation '\(name)'"
	}
	
	func invoke(withInputArgs inputArgs: [String], output: CommandOutput, context: CommandContext) {
		let rawLHS = inputArgs[0]
		let rawRHS = inputArgs[1]
		
		guard let lhs = Int(rawLHS) else {
			output.append("Left-hand side `\(rawLHS)` is not an integer")
			return
		}
		guard let rhs = Int(rawRHS) else {
			output.append("Right-hand side `\(rawRHS)` is not an integer")
			return
		}
		
		output.append(String(operation(lhs, rhs)))
	}
}
