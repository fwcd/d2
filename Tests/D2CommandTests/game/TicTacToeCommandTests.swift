import XCTest
import D2TestUtils
@testable import D2Commands

final class TicTacToeCommandTests: XCTestCase {
	static var allTests = [
		("testInvocation", testInvocation)
	]
	
	func testInvocation() throws {
		let command = TwoPlayerGameCommand<TicTacToeMatch>()
		let output = CommandTestOutput()
		
		// TODO
	}
}
