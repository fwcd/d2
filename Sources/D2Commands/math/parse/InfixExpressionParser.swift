import D2Utils

/**
 * Matches a single numeric/symbolic token.
 * 1. capture group: a digit
 * 2. capture group: an opening parenthesis
 * 3. capture group: a closing parenthesis
 */
fileprivate let numTokenPattern = try! Regex(from: "(\\d+\\(?:.\\d+)?)|(\\()|(\\))")

public struct InfixExpressionParser: ExpressionParser {
	public init() {}
	
	public func parse(_ input: String) throws -> ExpressionASTNode {
		let splitted: [Substring] = input.split(separator: " ")
		let tokens = try splitted.map { (rawToken: Substring) -> String in
			let token = String(rawToken)
			if let parsedNumToken = numTokenPattern.firstGroups(in: token) {
				if let digitToken = parsedNumToken[1].nilIfEmpty {
					return digitToken
				} else if let openingParenthesisToken = parsedNumToken[2].nilIfEmpty {
					return openingParenthesisToken
				} else if let closingParenthesisToken = parsedNumToken[3].nilIfEmpty {
					return closingParenthesisToken
				} else {
					throw ExpressionError.unhandledToken(token)
				}
			} else {
				return token
			}
		}
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
				operandStack.append(op(lhs, rhs))
			} else if let constant = expressionConstants[token] {
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
