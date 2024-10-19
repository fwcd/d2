import XCTest
import D2MessageIO
import D2TestUtils
@testable import D2Handlers

final class LuckyNumberHandlerTests: XCTestCase {
    func testLuckyNumbers() async {
        let handler = await LuckyNumberHandler(luckyNumbers: [42])
        var isLucky: Bool

        isLucky = await handler.isLucky(12)
        XCTAssertFalse(isLucky)

        isLucky = await handler.isLucky(41)
        XCTAssertFalse(isLucky)

        isLucky = await handler.isLucky(42)
        XCTAssertTrue(isLucky)

        isLucky = await handler.isLucky(420)
        XCTAssertFalse(isLucky)
    }

    func testPowerOfTenLuckyNumbers() async {
        let handler = await LuckyNumberHandler(luckyNumbers: [42], acceptPowerOfTenMultiples: true)
        var isLucky: Bool

        isLucky = await handler.isLucky(12)
        XCTAssertFalse(isLucky)

        isLucky = await handler.isLucky(41)
        XCTAssertFalse(isLucky)

        isLucky = await handler.isLucky(42)
        XCTAssertTrue(isLucky)

        isLucky = await handler.isLucky(420)
        XCTAssertTrue(isLucky)
    }

    func testMessageTrigger() async {
        let handler = await LuckyNumberHandler(luckyNumbers: [42])
        let output = await TestOutput()

        let message = Message(
            content: "40 is a nice number and so is 2",
            channelId: ID("Dummy Channel")
        )
        await output.modify {
            $0.messages.append(message)
        }
        _ = await handler.handle(message: message, sink: output)

        let lastContent = await output.lastContent
        XCTAssertEqual(lastContent, """
            All the numbers in your message added up to 42. Congrats!
            ```
            40 + 2 = 42
            ```
            """)
    }
}
