import XCTest
import D2MessageIO
import D2TestUtils
@testable import D2Commands

final class FindKeyCommandTests: XCTestCase {
    func testFindKey() async throws {
        return // FIXME: Re-enable this test once Sink etc. are async, otherwise the awaits might not actually await

        let command = FindKeyCommand()
        let output = TestOutput()

        await command.testInvoke(with: .text("C"), output: output)
        XCTAssertEqual(output.lastContent, "Possible keys: C Cm Db Dm Eb Em F Fm G Gm Ab Am Bb Bbm")

        await command.testInvoke(with: .text("E Eb"), output: output)
        XCTAssertEqual(output.lastContent, "Possible keys: ")

        await command.testInvoke(with: .text("C Db E"), output: output)
        XCTAssertEqual(output.lastContent, "Possible keys: ")

        await command.testInvoke(with: .text("C Db Eb"), output: output)
        XCTAssertEqual(output.lastContent, "Possible keys: Db Fm Ab Bbm")
    }
}
