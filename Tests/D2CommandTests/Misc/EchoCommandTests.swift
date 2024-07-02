import XCTest
import D2TestUtils
@testable import D2Commands

final class EchoCommandTests: XCTestCase {
    func testInvocation() async throws {
        return // FIXME: Re-enable this test once Sink etc. are async, otherwise the awaits might not actually await

        let command = EchoCommand()
        let output = TestOutput()

        await command.testInvoke(with: .text("demo"), output: output)
        XCTAssertEqual(output.lastContent, "demo")
    }
}
