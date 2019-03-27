import SwiftDiscord

class BinaryOperationCommand<T: LosslessStringConvertible>: ArgListCommand {
	let name: String
	let description: String
	let requiredPermissionLevel = PermissionLevel.basic
	let expectedArgCount: Int = 2
	
	private let operation: (T, T) -> T
	
	init(name: String, operation: @escaping (T, T) -> T) {
		self.name = name
		self.operation = operation
		description = "Performs the binary operation '\(name)'"
	}
	
	func invoke(withInputArgs inputArgs: [String], output: CommandOutput, context: CommandContext) {
		let rawLHS = inputArgs[0]
		let rawRHS = inputArgs[1]
		
		guard let lhs = T.init(rawLHS) else {
			output.append("Left-hand side `\(rawLHS)` is not a number")
			return
		}
		guard let rhs = T.init(rawRHS) else {
			output.append("Right-hand side `\(rawRHS)` is not a number")
			return
		}
		
		output.append(String(operation(lhs, rhs)))
	}
}
