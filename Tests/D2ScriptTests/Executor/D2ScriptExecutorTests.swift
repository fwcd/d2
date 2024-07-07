import XCTest
@testable import D2Script

final class D2ScriptExecutorTests: XCTestCase {
    func testExecutor() async throws {
        let executor = D2ScriptExecutor()
        let parser = D2ScriptParser()
        let script = try parser.parse("""
            command test {
                testPrint("A")
                testPrint("B")
            }
            """)

        var output = [[D2ScriptValue?]]()
        executor.topLevelStorage[function: "testPrint"] = {
            output.append($0)
            return nil
        }
        XCTAssert(executor.topLevelStorage.commandNames.isEmpty)

        await executor.run(script)
        XCTAssert(output.isEmpty)
        XCTAssertEqual(executor.topLevelStorage.commandNames, ["test"])

        await executor.call(command: "test")
        XCTAssertEqual(output, [[.string("A")], [.string("B")]])
    }
}
