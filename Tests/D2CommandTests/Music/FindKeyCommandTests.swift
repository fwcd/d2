import XCTest
import D2MessageIO
import D2TestUtils
@testable import D2Commands

final class FindKeyCommandTests: XCTestCase {
    func testFindKey() async throws {
        let command = await FindKeyCommand()
        let output = await TestOutput()
        var lastContent: String?

        await command.testInvoke(with: .text("C"), output: output)
        lastContent = await output.lastContent
        XCTAssertEqual(lastContent, "Possible keys: C Cm Db Dm Eb Em F Fm G Gm Ab Am Bb Bbm")

        await command.testInvoke(with: .text("E Eb"), output: output)
        lastContent = await output.lastContent
        XCTAssertEqual(lastContent, "Possible keys: ")

        await command.testInvoke(with: .text("C Db E"), output: output)
        lastContent = await output.lastContent
        XCTAssertEqual(lastContent, "Possible keys: ")

        await command.testInvoke(with: .text("C Db Eb"), output: output)
        lastContent = await output.lastContent
        XCTAssertEqual(lastContent, "Possible keys: Db Fm Ab Bbm")
    }
}
