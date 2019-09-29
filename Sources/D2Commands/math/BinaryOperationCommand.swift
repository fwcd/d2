import SwiftDiscord
import D2Permissions

public class BinaryOperationCommand<T: LosslessStringConvertible>: ArgCommand {
	public let name: String
	public let description: String
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	public let expectedArgCount: Int = 2
	
	private let operation: (T, T) -> T
	
	public init(name: String, operation: @escaping (T, T) -> T) {
		self.name = name
		self.operation = operation
		description = name
	}
	
	public func invoke(withInputArgs inputArgs: [String], output: CommandOutput, context: CommandContext) {
		let rawLHS = inputArgs[0]
		let rawRHS = inputArgs[1]
		
		guard let lhs = T.init(rawLHS) else {
			output.append("Left-hand side `\(rawLHS)` could not be parsed")
			return
		}
		guard let rhs = T.init(rawRHS) else {
			output.append("Right-hand side `\(rawRHS)` could not be parsed")
			return
		}
		
		output.append(String(operation(lhs, rhs)))
	}
}
