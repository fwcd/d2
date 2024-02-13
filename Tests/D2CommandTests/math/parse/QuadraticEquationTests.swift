import XCTest
import Utils
@testable import D2Commands

fileprivate let eps = 0.00001

final class QuadraticEquationTests: XCTestCase {
    func testParsing() throws {
        XCTAssertEqual(try QuadraticEquation(parsing: "x^2 = 0"), .init(a: 1, b: 0, c: 0))
        XCTAssertEqual(try QuadraticEquation(parsing: "x = 0"), .init(a: 0, b: 1, c: 0))
        XCTAssertEqual(try QuadraticEquation(parsing: "x^2 + x = 0"), .init(a: 1, b: 1, c: 0))
        XCTAssertEqual(try QuadraticEquation(parsing: "x^2 - x = 0"), .init(a: 1, b: -1, c: 0))
        XCTAssertEqual(try QuadraticEquation(parsing: "4 x^2 - x = 0"), .init(a: 4, b: -1, c: 0))
        XCTAssertEqual(try QuadraticEquation(parsing: "4 x^2 - 3/2 x = 0"), .init(a: 4, b: -Rational(3, 2), c: 0))
    }
}
