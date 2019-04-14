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
			} else if let op = expressionBinaryOperators[token] {
				guard let rhs = operandStack.popLast() else { throw ExpressionError.tooFewOperands(token) }
				guard let lhs = operandStack.popLast() else { throw ExpressionError.tooFewOperands(token) }
				operandStack.append(op.factory(lhs, rhs))
			} else if let constant = expressionConstants[token] {
				operandStack.append(constant)
			} else if token.isAlphabetic {
				let node = PlaceholderNode(name: token)
				
				if integerVariableNames.contains(token) {
					operandStack.append(FloorNode(value: node))
				} else {
					operandStack.append(node)
				}
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
