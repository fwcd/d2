import XCTest
import D2TestUtils
@testable import D2Commands

final class TicTacToeCommandTests: XCTestCase {
	static var allTests = [
		("testInvocation", testInvocation)
	]
	
	func testInvocation() throws {
		let command = TwoPlayerGameCommand<TicTacToeState>(withName: "tic tac toe")
		let output = CommandTestOutput()
		
		let playerX = GamePlayer(username: "Mr. X")
		let playerO = GamePlayer(username: "Mr. O")
		
		command.startMatch(between: playerX, and: playerO, output: output)
	}
}
