import SwiftDiscord

class BinaryDoubleOperationCommand: ArgListCommand {
	let name: String
	let description: String
	let requiredPermissionLevel = PermissionLevel.basic
	let expectedArgCount: Int = 2
	
	private let operation: (Double, Double) -> Double
	
	init(name: String, operation: @escaping (Double, Double) -> Double) {
		self.name = name
		self.operation = operation
		description = "Performs the binary operation '\(name)'"
	}
	
	func invoke(withInputArgs inputArgs: [String], output: CommandOutput, context: CommandContext) {
		let rawLHS = inputArgs[0]
		let rawRHS = inputArgs[1]
		
		guard let lhs = Double(rawLHS) else {
			output.append("Left-hand side `\(rawLHS)` is not a number")
			return
		}
		guard let rhs = Double(rawRHS) else {
			output.append("Right-hand side `\(rawRHS)` is not a number")
			return
		}
		
		output.append(String(operation(lhs, rhs)))
	}
}
