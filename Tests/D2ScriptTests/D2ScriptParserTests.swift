import XCTest
@testable import D2Script

final class D2ScriptParserTests: XCTestCase {
	static var allTests = [
		("testTokenization", testTokenization),
		("testParsing", testParsing)
	]
	private let eps = 0.01
	private let parser = D2ScriptParser()
	
	func testTokenization() throws {
		assertTokensEqual(try parser.tokenize("4.645"), [.numberLiteral(4.645)])
		assertTokensEqual(try parser.tokenize("\"\""), [.stringLiteral("")])
		assertTokensEqual(try parser.tokenize("(({}, {}), ())"), [
			.leftParenthesis, .leftParenthesis, .leftCurlyBracket, .rightCurlyBracket, .comma,
			.leftCurlyBracket, .rightCurlyBracket, .rightParenthesis, .comma,
			.leftParenthesis, .rightParenthesis, .rightParenthesis
		])
		
		let simpleProgram = """
			command test {
				a = 4.3
				b = "This is a string literal 12345"
				print(someFunction(b))
			}
			"""
		let tokens = try parser.tokenize(simpleProgram)
		assertTokensEqual(tokens, [
			.keyword("command"), .identifier("test"), .leftCurlyBracket, .linebreak,
			.identifier("a"), .anyOperator("="), .numberLiteral(4.3), .linebreak,
			.identifier("b"), .anyOperator("="), .stringLiteral("This is a string literal 12345"), .linebreak,
			.identifier("print"), .leftParenthesis, .identifier("someFunction"), .leftParenthesis, .identifier("b"), .rightParenthesis, .rightParenthesis, .linebreak,
			.rightCurlyBracket
		])
	}
	
	func testParsing() throws {
		let simpleProgram1 = """
			command simpleProgram {
				print("Hello world!")
				someFunction("Test argument", "ABC")
			}
			"""
		let ast = try parser.parse(simpleProgram1)
		XCTAssertEqual(ast.topLevelNodes.count, 1, "Expected exactly one top-level declaration: The command")
		
		let command = ast.topLevelNodes.first as? D2ScriptCommandDeclaration
		XCTAssertEqual(command?.commandName, "simpleProgram", "Expected a command labelled 'simpleProgram'")
		
		let statements = command?.statementList.statements
		XCTAssertEqual(statements?.count, 2, "Expected two statements")
		
		let firstPrint = (statements?[0] as? D2ScriptExpressionStatement)?.expression as? D2ScriptFunctionCall
		let secondCall = (statements?[1] as? D2ScriptExpressionStatement)?.expression as? D2ScriptFunctionCall
		XCTAssertEqual(firstPrint?.functionName, "print")
		XCTAssertEqual(secondCall?.functionName, "someFunction")
		
		assertExpressionsEqual(firstPrint!.arguments, [.string("Hello world!")])
		assertExpressionsEqual(secondCall!.arguments, [.string("Test argument"), .string("ABC")])
	}
	
	private func assertExpressionsEqual(_ actual: [D2ScriptExpression], _ expected: [D2ScriptValue]) {
		guard actual.count == expected.count else {
			XCTFail("The actual expression count \(actual.count) (\(format(actual))) does not match the expected token count \(expected.count) (\(format(expected)))")
			return
		}
	}
	
	private func assertTokensEqual(_ actual: [D2ScriptToken], _ expected: [D2ScriptToken]) {
		guard actual.count == expected.count else {
			XCTFail("The actual token count \(actual.count) (\(format(actual))) does not match the expected token count \(expected.count) (\(format(expected)))")
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
	
	private func format<T>(_ values: [T]) -> String {
		return "[\(values.map { "\($0)" }.joined(separator: "\n"))]"
	}
}
