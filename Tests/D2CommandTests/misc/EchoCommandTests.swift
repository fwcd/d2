import XCTest
import D2TestUtils
@testable import D2Commands

final class EchoCommandTests: XCTestCase {
	func testInvocation() throws {
		let command = EchoCommand()
		let output = CommandTestOutput()

		command.testInvoke(with: .text("demo"), output: output)
		XCTAssertEqual(output.lastContent, "demo")
	}
}
