import XCTest
@testable import D2Script

final class D2ScriptASTVisitorTests: XCTestCase {
    func testVisitor() throws {
        let visitor = DescribingASTVisitor()
        let script: D2ScriptASTNode = D2Script(topLevelNodes: [])
        let statement: D2ScriptASTNode = D2ScriptAssignment(identifier: "Test", expression: D2ScriptValue.string("Nothing"))
        let functionCall: D2ScriptASTNode = D2ScriptFunctionCall(functionName: "Test", arguments: [])
        let unrecognized: D2ScriptASTNode = D2ScriptValue.number(0)

        XCTAssertEqual(script.accept(visitor), "Found a script")
        XCTAssertEqual(statement.accept(visitor), "Found a statement")
        XCTAssertEqual(functionCall.accept(visitor), "Found a function call")
        XCTAssertEqual(unrecognized.accept(visitor), "Found unrecognized node")
    }
}
