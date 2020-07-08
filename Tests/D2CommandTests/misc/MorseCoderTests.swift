import XCTest
@testable import D2Commands

final class MorseCoderTests: XCTestCase {
    static var allTests = [
        ("testMorseCoder", testMorseCoder)
    ]
    
    func testMorseCoder() throws {
        let input = "the quick brown fox jumps over the lazy dog."
        let output = morseEncode(input)

        XCTAssertEqual(output, "- .... .   --.- ..- .. -.-. -.-   -... .-. --- .-- -.   ..-. --- -..-   .--- ..- -- .--. ...   --- ...- . .-.   - .... .   .-.. .- --.. -.--   -.. --- --. .-.-.-")
        XCTAssertEqual(morseDecode(output), input)
    }
}
