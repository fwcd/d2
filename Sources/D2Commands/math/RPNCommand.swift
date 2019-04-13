import SwiftDiscord
import D2Permissions

public class RPNCommand: StringCommand {
	public let description = "Evaluates an expression in Reverse Polish Notation"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			output.append(String(try RPNExpressionParser().parse(input).evaluate()))
		} catch ExpressionError.invalidOperator(let op) {
			output.append("Found invalid operator: `\(op)`")
		} catch ExpressionError.tooFewOperands(let op) {
			output.append("Operator `\(op)` has too few operands")
		} catch ExpressionError.emptyResult {
			output.append("The expression yielded no result")
		} catch {
			print(error)
			output.append("Error while computing RPN")
		}
	}
}
