import D2MessageIO
import D2Permissions

public class BinaryOperationCommand<T: LosslessStringConvertible>: ArgCommand {
	public let info: CommandInfo
	public let name: String
	public let outputValueType: RichValueType = .text
	public let argPattern = ArgPair(
		patternWithLeft: ArgValue(name: "lhs", examples: []),
		right: ArgValue(name: "rhs", examples: [])
	)

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

	public func invoke(with input: Args, output: CommandOutput, context: CommandContext) {
		let rawLHS = input.left.value
		let rawRHS = input.right.value

		guard let lhs = T.init(rawLHS) else {
			output.append(errorText: "Left-hand side `\(rawLHS)` could not be parsed")
			return
		}
		guard let rhs = T.init(rawRHS) else {
			output.append(errorText: "Right-hand side `\(rawRHS)` could not be parsed")
			return
		}

		output.append(String(operation(lhs, rhs)))
	}
}
