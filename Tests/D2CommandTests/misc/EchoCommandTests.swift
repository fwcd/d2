import XCTest
import D2TestUtils
@testable import D2Commands

final class EchoCommandTests: XCTestCase {
	static var allTests = [
		("testInvocation", testInvocation)
	]

	func testInvocation() throws {
		let command = EchoCommand()
		let output = CommandTestOutput()

		command.testinvoke(with: .text("demo"), output: output)
		XCTAssertEqual(output.lastContent, "demo")
	}
}
