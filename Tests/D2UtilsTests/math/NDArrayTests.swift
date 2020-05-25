import XCTest
@testable import D2Utils

final class NDArrayTests: XCTestCase {
    static var allTests = [
        ("testNDArrayParser", testNDArrayParser)
    ]
    
    func testNDArrayParser() throws {
        let parser = NDArrayParser()

        XCTAssertEqual(try parser.parse("3"), NDArray(3))
        XCTAssertEqual(try parser.parse("(1, 2)"), NDArray([1, 2]))
        XCTAssertEqual(try parser.parse("((4), (2))"), try NDArray([[4], [2]]))
    }
}