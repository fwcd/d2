import SwiftDiscord
import D2Permissions

fileprivate let binaryOperators: [String: (Double, Double) -> Double] = [
	"+": { $0 + $1 },
	"-": { $0 - $1 },
	"*": { $0 * $1 },
	"/": { $0 / $1 }
]

public class RPNCommand: StringCommand {
	public let description = "Evaluates an expression in Reverse Polish Notation"
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			let tokens = input.split(separator: " ").map { String($0) }
			output.append(String(try computeRPN(tokens: tokens)))
		} catch ExpressionParseError.invalidOperator(let op) {
			output.append("Found invalid operator: `\(op)`")
		} catch ExpressionParseError.tooFewOperands(let op) {
			output.append("Operator `\(op)` has too few operands")
		} catch ExpressionParseError.emptyResult {
			output.append("The expression yielded no result")
		} catch {
			print(error)
			output.append("Error while computing RPN")
		}
	}
	
	private func computeRPN(tokens: [String]) throws -> Double {
		var operandStack = [Double]()
		
		for token in tokens {
			if let number = Double(token) {
				operandStack.append(number)
			} else if let op = binaryOperators[token] {
				guard let rhs = operandStack.popLast() else { throw ExpressionParseError.tooFewOperands(token) }
				guard let lhs = operandStack.popLast() else { throw ExpressionParseError.tooFewOperands(token) }
				operandStack.append(op(lhs, rhs))
			} else {
				throw ExpressionParseError.invalidOperator(token)
			}
		}
		
		if let result = operandStack.popLast() {
			return result
		} else {
			throw ExpressionParseError.emptyResult
		}
	}
}
