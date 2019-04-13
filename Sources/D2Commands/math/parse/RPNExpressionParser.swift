fileprivate let binaryOperators: [String: (ExpressionASTNode, ExpressionASTNode) -> ExpressionASTNode] = [
	"+": { SumNode(lhs: $0, rhs: $1) },
	"-": { DifferenceNode(lhs: $0, rhs: $1) },
	"*": { ProductNode(lhs: $0, rhs: $1) },
	"/": { QuotientNode(lhs: $0, rhs: $1) },
	"^": { ExponentiationNode(lhs: $0, rhs: $1) }
]

fileprivate let mathConstants: [String: ExpressionASTNode] = [
	"e": ConstantNode(value: 2.71828182845904523536),
	"pi": ConstantNode(value: .pi)
]

public struct RPNExpressionParser: ExpressionParser {
	public init() {}
	
	public func parse(_ input: String) throws -> ExpressionASTNode {
		let tokens = input.split(separator: " ").map { String($0) }
		return try parseRPNTree(tokens: tokens)
	}
	
	private func parseRPNTree(tokens: [String]) throws -> ExpressionASTNode {
		var operandStack = [ExpressionASTNode]()
		
		for token in tokens {
			if let number = Double(token) {
				operandStack.append(ConstantNode(value: number))
			} else if let op = binaryOperators[token] {
				guard let rhs = operandStack.popLast() else { throw ExpressionError.tooFewOperands(token) }
				guard let lhs = operandStack.popLast() else { throw ExpressionError.tooFewOperands(token) }
				operandStack.append(op(lhs, rhs))
			} else if let constant = mathConstants[token] {
				operandStack.append(constant)
			} else if token.isAlphabetic {
				operandStack.append(PlaceholderNode(name: token))
			} else {
				throw ExpressionError.invalidOperator(token)
			}
		}
		
		if let result = operandStack.popLast() {
			return result
		} else {
			throw ExpressionError.emptyResult
		}
	}
}
