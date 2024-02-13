import XCTest
import D2MessageIO
import D2TestUtils
@testable import D2Handlers

final class LuckyNumberHandlerTests: XCTestCase {
    func testLuckyNumbers() {
        let handler = LuckyNumberHandler(luckyNumbers: [42])

        XCTAssertFalse(handler.isLucky(12))
        XCTAssertFalse(handler.isLucky(41))
        XCTAssertTrue(handler.isLucky(42))
        XCTAssertFalse(handler.isLucky(420))
    }

    func testPowerOfTenLuckyNumbers() {
        let handler = LuckyNumberHandler(luckyNumbers: [42], acceptPowerOfTenMultiples: true)

        XCTAssertFalse(handler.isLucky(12))
        XCTAssertFalse(handler.isLucky(41))
        XCTAssertTrue(handler.isLucky(42))
        XCTAssertTrue(handler.isLucky(420))
    }

    func testMessageTrigger() {
        let handler = LuckyNumberHandler(luckyNumbers: [42])
        let output = TestOutput()

        let message = Message(
            content: "40 is a nice number and so is 2",
            channelId: ID("Dummy Channel")
        )
        output.messages.append(message)
        _ = handler.handle(message: message, from: output)

        XCTAssertEqual(output.lastContent, """
            All the numbers in your message added up to 42. Congrats!
            ```
            40 + 2 = 42
            ```
            """)
    }
}
