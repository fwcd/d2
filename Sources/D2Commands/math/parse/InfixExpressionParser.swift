import D2Utils

fileprivate let rawBinaryOperatorPattern = expressionBinaryOperators.keys
	.map { "(?:\(Regex.escape($0)))" }
	.joined(separator: "|")

/**
 * Matches a single token.
 * 1. capture group: a number
 * 2. capture group: an opening parenthesis
 * 3. capture group: a closing parenthesis
 * 4. capture group: an identifier
 * 5. capture group: a binary operator
 */
fileprivate let tokenPattern = try! Regex(from: "(\\d+(?:.\\d+)?)|(\\()|(\\))|([a-zA-Z]+)|(\(rawBinaryOperatorPattern))")

public struct InfixExpressionParser: ExpressionParser {
	public init() {}
	
	public func parse(_ input: String) throws -> ExpressionASTNode {
		return try parseExpression(from: TokenIterator(try tokenize(input)), minPrecedence: 1 /* TODO */)
	}
	
	/** Breaks up the input string into tokens that are processed later. */
	private func tokenize(_ str: String) throws -> [InfixExpressionToken] {
		return try tokenPattern.allGroups(in: str)
			.map {
				if !$0[1].isEmpty { // Parse number
					guard let value = Double($0[1]) else { throw ExpressionError.invalidNumber($0[1]) }
					return .number(value)
				} else if !$0[2].isEmpty {
					return .openingParenthesis
				} else if !$0[3].isEmpty {
					return .closingParenthesis
				} else if !$0[4].isEmpty {
					return .identifier($0[4])
				} else if !$0[5].isEmpty {
					return .binaryOperator($0[5])
				} else {
					throw ExpressionError.unrecognizedToken($0[0])
				}
			}
	}
	
	// The parser is based on https://eli.thegreenplace.net/2012/08/02/parsing-expressions-by-precedence-climbing
	
	/** Parses an atom (such as a parenthesized expression or a literal). */
	private func parseAtom(from tokens: TokenIterator<InfixExpressionToken>) throws -> ExpressionASTNode {
		guard let token = tokens.next() else { throw ExpressionError.unexpectedEnd }
		switch token {
			case .number(let value):
				return ConstantNode(value: value)
			case .identifier(let name):
				let node = PlaceholderNode(name: name)
				
				if integerVariableNames.contains(name) {
					return FloorNode(value: node)
				} else {
					return node
				}
			case .openingParenthesis:
				let value = try parseExpression(from: tokens, minPrecedence: 1)
				guard (tokens.peek().map { $0 == .closingParenthesis } ?? false) else { throw ExpressionError.parenthesesMismatch("Expected closing parenthesis, but was \(String(describing: tokens.peek()))") }
				return value
			default:
				throw ExpressionError.unhandledToken(token)
		}
	}
	
	/** Use precedence climbing a sequence of tokens as an infix expression. */
	private func parseExpression(from tokens: TokenIterator<InfixExpressionToken>, minPrecedence: Int) throws -> ExpressionASTNode {
		var result = try parseAtom(from: tokens)
		
		while case let .binaryOperator(rawOperator)? = tokens.peek() {
			guard let op = expressionBinaryOperators[rawOperator] else { throw ExpressionError.invalidOperator(rawOperator) }
			guard op.precedence >= minPrecedence else { break }
			let nextMinPrecedence: Int
			
			tokens.next()
			
			switch op.associativity {
				case .left: nextMinPrecedence = op.precedence + 1
				case .right: nextMinPrecedence = op.precedence
			}
			
			let rhs = try parseExpression(from: tokens, minPrecedence: nextMinPrecedence)
			result = op.factory(result, rhs)
		}
		
		return result
	}
}
