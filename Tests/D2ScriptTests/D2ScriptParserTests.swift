import XCTest
@testable import D2Script

final class D2ScriptParserTests: XCTestCase {
	static var allTests = [
		("testTokenization", testTokenization)
	]
	private let eps = 0.01
	private let parser = D2ScriptParser()
	
	func testTokenization() throws {
		let simpleProgram = """
			command test {
				a = 4.3
				b = "This is a string literal 12345"
				print(someFunction(b))
			}
			"""
		let tokens = try parser.tokenize(simpleProgram)
		assertTokensEqual(tokens, [
			.keyword("command"),
			.identifier("test"),
			.leftCurlyBracket,
			.linebreak,
			.identifier("a"),
			.anyOperator("="),
			.numberLiteral(4.3),
			.linebreak,
			.identifier("b"),
			.anyOperator("="),
			.stringLiteral("This is a string literal 12345"),
			.linebreak,
			.identifier("print"),
			.leftParenthesis,
			.identifier("someFunction"),
			.leftParenthesis,
			.identifier("b"),
			.rightParenthesis,
			.rightParenthesis,
			.linebreak,
			.rightCurlyBracket
		])
	}
	
	private func assertTokensEqual(_ actual: [D2ScriptToken], _ expected: [D2ScriptToken]) {
		guard actual.count == expected.count else {
			XCTFail("The actual token count \(actual.count) (\(format(tokens: actual))) does not match the expected token count \(expected.count) (\(format(tokens: expected)))")
			return
		}
		let count = actual.count
		for i in 0..<count {
			let expectedToken = expected[i]
			let actualToken = actual[i]
			
			if case let .numberLiteral(expectedValue) = expectedToken {
				guard case let .numberLiteral(actualValue) = actualToken else {
					XCTFail("Expected the number token \(expectedToken), but was \(actualToken)")
					return
				}
				// Ensure that numeric tokens are not compared directly
				// since that could result in floating point inaccuracies
				XCTAssertEqual(expectedValue, actualValue, accuracy: eps)
			} else {
				XCTAssertEqual(actualToken, expectedToken)
			}
		}
	}
	
	private func format(tokens: [D2ScriptToken]) -> String {
		return "[\(tokens.map { "\($0)" }.joined(separator: "\n"))]"
	}
}
