import XCTest
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
}
