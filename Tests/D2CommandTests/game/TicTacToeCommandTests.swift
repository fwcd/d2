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
		
		let nameX = "Mr. X"
		let nameO = "Mr. O"
		let playerX = GamePlayer(username: nameX)
		let playerO = GamePlayer(username: nameO)
		
		command.startMatch(between: playerX, and: playerO, output: output)
		
		let x = ":x:"
		let o = ":o:"
		let empty = ":white_large_square:"
		
		let header = "Playing new match: `\(nameX)` as \(x) vs `\(nameO)` as \(o)"
		let board = "\(empty)\(empty)\(empty)\n\(empty)\(empty)\(empty)\n\(empty)\(empty)\(empty)"
		XCTAssertEqual(output.lastContent, "\(header)\n\(board)\nType `move [...]` to begin!")
	}
}
