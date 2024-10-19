import Testing
import D2TestUtils
@testable import D2Commands

struct EchoCommandTests {
    @Test func invocation() async {
        let command = await EchoCommand()
        let output = await TestOutput()

        await command.testInvoke(with: .text("demo"), output: output)
        #expect(await output.lastContent == "demo")
    }
}
