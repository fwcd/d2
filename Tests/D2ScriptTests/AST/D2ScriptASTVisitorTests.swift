import Testing
@testable import D2Script

struct D2ScriptASTVisitorTests {
    @Test func visitor() async {
        let visitor = DescribingASTVisitor()
        let script: any D2ScriptASTNode = D2Script(topLevelNodes: [])
        let statement: any D2ScriptASTNode = D2ScriptAssignment(identifier: "Test", expression: D2ScriptValue.string("Nothing"))
        let functionCall: any D2ScriptASTNode = D2ScriptFunctionCall(functionName: "Test", arguments: [])
        let unrecognized: any D2ScriptASTNode = D2ScriptValue.number(0)

        #expect(await script.accept(visitor) == "Found a script")
        #expect(await statement.accept(visitor) == "Found a statement")
        #expect(await functionCall.accept(visitor) == "Found a function call")
        #expect(await unrecognized.accept(visitor) == "Found unrecognized node")
    }
}
