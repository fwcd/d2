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
		let e = ":white_large_square:"
		
		let header = "Playing new match: `\(nameX)` as \(x) vs. `\(nameO)` as \(o)"
		let board = "\(e)\(e)\(e)\n\(e)\(e)\(e)\n\(e)\(e)\(e)"
		XCTAssertEqual(output.lastContent, "\(header)\n\(board)\nType `move [...]` to begin!")
		
		command.move(withArgs: ["top left"], output: output, author: playerO)
		XCTAssertEqual(output.lastContent, "It is not your turn, `\(nameO)`")
		
		command.move(withArgs: ["top left"], output: output, author: playerX)
		XCTAssertEqual(output.lastContent, "\(x)\(e)\(e)\n\(e)\(e)\(e)\n\(e)\(e)\(e)")
		
		command.move(withArgs: ["top right"], output: output, author: playerX)
		XCTAssertEqual(output.lastContent, "It is not your turn, `\(nameX)`")
		
		command.move(withArgs: ["center center"], output: output, author: playerO)
		XCTAssertEqual(output.lastContent, "\(x)\(e)\(e)\n\(e)\(o)\(e)\n\(e)\(e)\(e)")
		
		command.move(withArgs: ["left bottom"], output: output, author: playerX)
		XCTAssertEqual(output.lastContent, "\(x)\(e)\(e)\n\(e)\(o)\(e)\n\(x)\(e)\(e)")
		
		command.move(withArgs: ["0 2"], output: output, author: playerO)
		XCTAssertEqual(output.lastContent, "\(x)\(e)\(o)\n\(e)\(o)\(e)\n\(x)\(e)\(e)")
		
		command.move(withArgs: ["1 0"], output: output, author: playerX)
		XCTAssertEqual(output.nthLastContent(2), "\(x)\(e)\(o)\n\(x)\(o)\(e)\n\(x)\(e)\(e)")
		
		let embed = output.last?.embeds.first
		XCTAssertEqual(embed?.title, ":crown: Winner")
		XCTAssertEqual(embed?.description, "\(x) aka. `\(nameX)` won the game!")
	}
}
