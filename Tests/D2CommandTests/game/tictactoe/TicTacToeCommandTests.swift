import XCTest
import D2MessageIO
import D2TestUtils
@testable import D2Commands

fileprivate let x = ":x:"
fileprivate let o = ":o:"
fileprivate let e = ":white_large_square:"
fileprivate let nameX = "Mr. X"
fileprivate let nameO = "Mr. O"

final class TicTacToeCommandTests: XCTestCase {
	static var allTests = [
		("testXWin", testXWin),
		("testDraw", testDraw)
	]
	private let playerX = GamePlayer(username: nameX)
	private let playerO = GamePlayer(username: nameO)

	func testXWin() throws {
		let command = GameCommand<TicTacToeGame>()
		let output = CommandTestOutput()
		let channel = dummyId
		command.startMatch(between: [playerX, playerO], on: channel, output: output)

		command.perform("move", withArgs: "top left", on: channel, output: output, author: playerO)
		XCTAssertEqual(output.lastEmbedDescription, ":warning: It is not your turn, `\(nameO)`")

		command.perform("move", withArgs: "top left", on: channel, output: output, author: playerX)
		XCTAssertEqual(output.lastContent, "\(x)\(e)\(e)\n\(e)\(e)\(e)\n\(e)\(e)\(e)")

		command.perform("move", withArgs: "top right", on: channel, output: output, author: playerX)
		XCTAssertEqual(output.lastEmbedDescription, ":warning: It is not your turn, `\(nameX)`")

		command.perform("move", withArgs: "center center", on: channel, output: output, author: playerO)
		XCTAssertEqual(output.lastContent, "\(x)\(e)\(e)\n\(e)\(o)\(e)\n\(e)\(e)\(e)")

		command.perform("move", withArgs: "left bottom", on: channel, output: output, author: playerX)
		XCTAssertEqual(output.lastContent, "\(x)\(e)\(e)\n\(e)\(o)\(e)\n\(x)\(e)\(e)")

		command.perform("move", withArgs: "0 2", on: channel, output: output, author: playerO)
		XCTAssertEqual(output.lastContent, "\(x)\(e)\(o)\n\(e)\(o)\(e)\n\(x)\(e)\(e)")

		command.perform("move", withArgs: "1 0", on: channel, output: output, author: playerX)
		XCTAssertEqual(output.lastContent, "\(x)\(e)\(o)\n\(x)\(o)\(e)\n\(x)\(e)\(e)")

		let result = output.last?.embeds.first
		XCTAssertEqual(result?.title, ":crown: Winner")
		XCTAssertEqual(result?.description, "\(x) aka. `\(nameX)` won the game!")
	}

	func testDraw() throws {
		let command = GameCommand<TicTacToeGame>()
		let output = CommandTestOutput()
		let channel = dummyId
		command.startMatch(between: [playerX, playerO], on: channel, output: output)

		command.perform("move", withArgs: "0 0", on: channel, output: output, author: playerX)
		command.perform("move", withArgs: "1 1", on: channel, output: output, author: playerO)
		command.perform("move", withArgs: "2 2", on: channel, output: output, author: playerX)
		command.perform("move", withArgs: "0 1", on: channel, output: output, author: playerO)
		command.perform("move", withArgs: "2 1", on: channel, output: output, author: playerX)
		command.perform("move", withArgs: "2 0", on: channel, output: output, author: playerO)
		command.perform("move", withArgs: "1 0", on: channel, output: output, author: playerX)
		command.perform("move", withArgs: "1 2", on: channel, output: output, author: playerO)
		command.perform("move", withArgs: "0 2", on: channel, output: output, author: playerX)

		let result = output.last?.embeds.first
		XCTAssertEqual(result?.title, ":crown: Game Over")
		XCTAssertEqual(result?.description, "The game resulted in a draw!")
	}
}
