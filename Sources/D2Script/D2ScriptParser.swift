import D2Utils

fileprivate let operators: [String] = ["=", "+", "-", "*", "/", "^"]
fileprivate let keywords: [String] = ["command", "if", "else", "for", "while"]

fileprivate let rawKeywordPattern = keywords
	.map { "(?:\(Regex.escape($0)))" }
	.joined(separator: "|")
fileprivate let rawOperatorPattern = operators
	.map { "(?:\(Regex.escape($0)))" }
	.joined(separator: "|")

/**
 * Matches a single token.
 * 1. capture group: a number literal
 * 2. capture group: an opening parenthesis
 * 3. capture group: a closing parenthesis
 * 4. capture group: an opening curly bracket
 * 5. capture group: a closing curly bracket
 * 6. capture group: an operator
 * 7. capture group: a keyword
 * 8. capture group: a string literal
 * 9. capture group: an identifier
 */
fileprivate let tokenPattern = try! Regex(from: "(\\d+(?:\\.\\d+)?)|(\\()|(\\))|({)|(})|(\(rawOperatorPattern))|(\(rawKeywordPattern))|(\\(\".+?\"\\))|([a-zA-Z]+)")

public struct D2ScriptParser {
	public func parse(_ input: String) throws -> D2Script {
		return try parse(tokens: try tokenize(input))
	}
	
	func tokenize(_ input: String) throws -> [D2ScriptToken] {
		return try tokenPattern.allGroups(in: input)
			.map {
				if let numberLiteral = $0[1].nilIfEmpty {
					guard let value = Double(numberLiteral) else { throw D2ScriptError.numberFormatError(numberLiteral) }
					return .numberLiteral(value)
				} else if !$0[2].isEmpty {
					return .leftParenthesis
				} else if !$0[3].isEmpty {
					return .rightParenthesis
				} else if !$0[4].isEmpty {
					return .leftCurlyBracket
				} else if !$0[5].isEmpty {
					return .rightCurlyBracket
				} else if let rawOperator = $0[6].nilIfEmpty {
					return .anyOperator(rawOperator)
				} else if let keyword = $0[7].nilIfEmpty {
					return .keyword(keyword)
				} else if let stringLiteral = $0[8].nilIfEmpty {
					return .stringLiteral(stringLiteral)
				} else if let identifier = $0[9].nilIfEmpty {
					return .identifier(identifier)
				} else {
					throw D2ScriptError.unrecognizedToken($0[0])
				}
			}
	}
	
	private func parse(tokens: [D2ScriptToken]) throws -> D2Script {
		// TODO
		return D2Script()
	}
}
