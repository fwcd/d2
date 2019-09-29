import SwiftDiscord
import D2Permissions

// TODO: Use Arg API

public class BinaryOperationCommand<T: LosslessStringConvertible>: ArgCommand {
	public let info: CommandInfo
	public let name: String
	public let expectedArgCount: Int = 2
	public let inputValueType: RichValueType = .text
	public let outputValueType: RichValueType = .text
	
	private let operation: (T, T) -> T
	
	public init(name: String, operation: @escaping (T, T) -> T) {
		self.name = name
		self.operation = operation
		info = CommandInfo(
			category: .math,
			shortDescription: "Performs \(name)",
			longDescription: "Performs the binary operation \(name)",
			requiredPermissionLevel: .basic
		)
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
