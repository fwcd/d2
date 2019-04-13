import SwiftDiscord
import D2Permissions

public class EvaluateExpressionCommand: StringCommand {
	public let description: String
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let parser: ExpressionParser
	
	public init(parser: ExpressionParser, name: String) {
		self.parser = parser
		description = "Evaluates an expression in \(name)"
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			output.append(String(try parser.parse(input).evaluate()))
		} catch ExpressionError.invalidOperator(let op) {
			output.append("Found invalid operator: `\(op)`")
		} catch ExpressionError.tooFewOperands(let op) {
			output.append("Operator `\(op)` has too few operands")
		} catch ExpressionError.emptyResult {
			output.append("The expression yielded no result")
		} catch {
			print(error)
			output.append("Error while parsing/evaluating expression")
		}
	}
}
