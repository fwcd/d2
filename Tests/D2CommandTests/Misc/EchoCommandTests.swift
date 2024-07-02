import XCTest
import D2TestUtils
@testable import D2Commands

final class EchoCommandTests: XCTestCase {
    func testInvocation() async throws {
        let command = EchoCommand()
        let output = TestOutput()

        await command.testInvoke(with: .text("demo"), output: output)
        XCTAssertEqual(output.lastContent, "demo")
    }
}
