import XCTest
import D2TestUtils
@testable import D2Commands

final class EchoCommandTests: XCTestCase {
    func testInvocation() async throws {
        let command = await EchoCommand()
        let output = await TestOutput()

        await command.testInvoke(with: .text("demo"), output: output)
        let lastContent = await output.lastContent
        XCTAssertEqual(lastContent, "demo")
    }
}
