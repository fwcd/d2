import Testing
@testable import D2Script

struct D2ScriptExecutorTests {
    @Test func executor() async throws {
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
        #expect(executor.topLevelStorage.commandNames.isEmpty)

        await executor.run(script)
        #expect(output.isEmpty)
        #expect(executor.topLevelStorage.commandNames == ["test"])

        await executor.call(command: "test")
        #expect(output == [[.string("A")], [.string("B")]])
    }
}
