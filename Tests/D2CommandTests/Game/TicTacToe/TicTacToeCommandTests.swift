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
    private let playerX = GamePlayer(username: nameX)
    private let playerO = GamePlayer(username: nameO)

    func testXWin() async throws {
        let command = await GameCommand<TicTacToeGame>()
        let output = await TestOutput()
        var lastContent: String?
        var lastEmbedDescription: String?

        let channel = dummyId
        await command.startMatch(between: [playerX, playerO], on: channel, output: output)

        await command.perform("move", withArgs: "top left", on: channel, output: output, author: playerO)
        lastEmbedDescription = await output.lastEmbedDescription
        XCTAssertEqual(lastEmbedDescription, ":warning: It is not your turn, `\(nameO)`")

        await command.perform("move", withArgs: "top left", on: channel, output: output, author: playerX)
        lastContent = await output.lastContent
        XCTAssertEqual(lastContent, "\(x)\(e)\(e)\n\(e)\(e)\(e)\n\(e)\(e)\(e)")

        await command.perform("move", withArgs: "top right", on: channel, output: output, author: playerX)
        lastEmbedDescription = await output.lastEmbedDescription
        XCTAssertEqual(lastEmbedDescription, ":warning: It is not your turn, `\(nameX)`")

        await command.perform("move", withArgs: "center center", on: channel, output: output, author: playerO)
        lastContent = await output.lastContent
        XCTAssertEqual(lastContent, "\(x)\(e)\(e)\n\(e)\(o)\(e)\n\(e)\(e)\(e)")

        await command.perform("move", withArgs: "left bottom", on: channel, output: output, author: playerX)
        lastContent = await output.lastContent
        XCTAssertEqual(lastContent, "\(x)\(e)\(e)\n\(e)\(o)\(e)\n\(x)\(e)\(e)")

        await command.perform("move", withArgs: "0 2", on: channel, output: output, author: playerO)
        lastContent = await output.lastContent
        XCTAssertEqual(lastContent, "\(x)\(e)\(o)\n\(e)\(o)\(e)\n\(x)\(e)\(e)")

        await command.perform("move", withArgs: "1 0", on: channel, output: output, author: playerX)
        lastContent = await output.lastContent
        XCTAssertEqual(lastContent, "\(x)\(e)\(o)\n\(x)\(o)\(e)\n\(x)\(e)\(e)")

        let result = await output.last?.embeds.first
        XCTAssertEqual(result?.title, ":crown: Winner")
        XCTAssertEqual(result?.description, "\(x) aka. `\(nameX)` won the game!")
    }

    func testDraw() async throws {
        let command = await GameCommand<TicTacToeGame>()
        let output = await TestOutput()
        let channel = dummyId
        await command.startMatch(between: [playerX, playerO], on: channel, output: output)

        await command.perform("move", withArgs: "0 0", on: channel, output: output, author: playerX)
        await command.perform("move", withArgs: "1 1", on: channel, output: output, author: playerO)
        await command.perform("move", withArgs: "2 2", on: channel, output: output, author: playerX)
        await command.perform("move", withArgs: "0 1", on: channel, output: output, author: playerO)
        await command.perform("move", withArgs: "2 1", on: channel, output: output, author: playerX)
        await command.perform("move", withArgs: "2 0", on: channel, output: output, author: playerO)
        await command.perform("move", withArgs: "1 0", on: channel, output: output, author: playerX)
        await command.perform("move", withArgs: "1 2", on: channel, output: output, author: playerO)
        await command.perform("move", withArgs: "0 2", on: channel, output: output, author: playerX)

        let result = await output.last?.embeds.first
        XCTAssertEqual(result?.title, ":crown: Game Over")
        XCTAssertEqual(result?.description, "The game resulted in a draw!")
    }
}
