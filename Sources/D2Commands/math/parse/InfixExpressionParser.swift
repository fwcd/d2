import D2Utils

/**
 * Matches a single numeric/symbolic token.
 * 1. capture group: a number
 * 2. capture group: an opening parenthesis
 * 3. capture group: a closing parenthesis
 */
fileprivate let numTokenPattern = try! Regex(from: "(\\d+\\(?:.\\d+)?)|(\\()|(\\))")

public struct InfixExpressionParser: ExpressionParser {
	public init() {}
	
	public func parse(_ input: String) throws -> ExpressionASTNode {
		let splitted: [Substring] = input.split(separator: " ")
		let tokens = try splitted.map { (rawToken: Substring) -> InfixExpressionToken in
			let token = String(rawToken)
			if let parsedNumToken = numTokenPattern.firstGroups(in: token) {
				if let numberToken = parsedNumToken[1].nilIfEmpty.flatMap({ Int($0) }) {
					return .number(numberToken)
				} else if !parsedNumToken[2].isEmpty {
					return .openingParenthesis
				} else if !parsedNumToken[3].isEmpty {
					return .closingParenthesis
				} else {
					throw ExpressionError.unhandledToken(token)
				}
			} else {
				return .other(token)
			}
		}
		return try parseInfixTree(tokens: tokens)
	}
	
	private func parseInfixTree(tokens: [InfixExpressionToken]) throws -> ExpressionASTNode {
		// TODO
		throw ExpressionError.emptyResult
	}
}
