import XCTest
import D2MessageIO
import D2TestUtils
@testable import D2Commands

final class FindKeyCommandTests: XCTestCase {
    func testFindKey() throws {
        let command = FindKeyCommand()
        let output = TestOutput()

        command.testInvoke(with: .text("C"), output: output)
        XCTAssertEqual(output.lastContent, "Possible keys: C Cm C# Db Dm D# Eb Em F Fm G Gm G# Ab Am A# A#m Bb Bbm")

        command.testInvoke(with: .text("E Eb"), output: output)
        XCTAssertEqual(output.lastContent, "Possible keys: C#m Dbm E G#m Abm B")

        command.testInvoke(with: .text("C Db E"), output: output)
        XCTAssertEqual(output.lastContent, "Possible keys: ")

        command.testInvoke(with: .text("C Db Eb"), output: output)
        XCTAssertEqual(output.lastContent, "Possible keys: Db Fm Ab Bbm")
    }
}
