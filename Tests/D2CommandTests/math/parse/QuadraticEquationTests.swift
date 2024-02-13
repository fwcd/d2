import XCTest
@testable import D2Commands

fileprivate let eps = 0.00001

final class QuadraticEquationTests: XCTestCase {
    func testParsing() throws {
        // TODO: Should we forbid this?
        XCTAssertEqual(try QuadraticEquation(parsing: "0 = 0"), .init(a: 0, b: 0, c: 0))
        XCTAssertEqual(try QuadraticEquation(parsing: "x^2 = 0"), .init(a: 1, b: 0, c: 0))
        XCTAssertEqual(try QuadraticEquation(parsing: "x = 0"), .init(a: 0, b: 1, c: 0))
    }
}
