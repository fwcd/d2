import XCTest
@testable import D2Script

final class D2ScriptASTVisitorTests: XCTestCase {
    func testVisitor() async throws {
        let visitor = DescribingASTVisitor()
        let script: any D2ScriptASTNode = D2Script(topLevelNodes: [])
        let statement: any D2ScriptASTNode = D2ScriptAssignment(identifier: "Test", expression: D2ScriptValue.string("Nothing"))
        let functionCall: any D2ScriptASTNode = D2ScriptFunctionCall(functionName: "Test", arguments: [])
        let unrecognized: any D2ScriptASTNode = D2ScriptValue.number(0)

        let scriptOutput = await script.accept(visitor)
        XCTAssertEqual(scriptOutput, "Found a script")

        let statementOutput = await statement.accept(visitor)
        XCTAssertEqual(statementOutput, "Found a statement")

        let functionCallOutput = await functionCall.accept(visitor)
        XCTAssertEqual(functionCallOutput, "Found a function call")

        let unrecognizedOutput = await unrecognized.accept(visitor)
        XCTAssertEqual(unrecognizedOutput, "Found unrecognized node")
    }
}
