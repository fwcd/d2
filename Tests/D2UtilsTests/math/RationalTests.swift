import XCTest
@testable import D2Utils

final class RationalTests: XCTestCase {
    static var allTests = [
        ("testRational", testRational)
    ]
    
    func testRational() throws {
        let a: Rational = 1 / 2
        let b = Rational(7, 6)

        XCTAssertEqual(a + b, Rational(20, 12))
        XCTAssertEqual((a + b).reduced, Rational(5, 3))
        XCTAssertEqual((a - b).reduced, Rational(-2, 3))
        XCTAssertEqual((a * b).reduced, Rational(7, 12))
        XCTAssertEqual((a / b).reduced, Rational(3, 7))
        XCTAssertEqual(Rational(34), Rational(68, 2).reduced)
        XCTAssertEqual(Rational(-43, 40), Rational(43, -40)) // Signs should automatically be normalized
        XCTAssertEqual(Rational(2, 8), Rational(-2, -8))
        XCTAssertEqual(Rational(2, -8).asDouble, -0.25, accuracy: 0.00001)
        XCTAssert(a < b)
        XCTAssert(Rational(2, 4) < Rational(2, 3))
        XCTAssert(Rational(1, 10) > -Rational(1, 10))
        XCTAssert(a > 0)
        XCTAssert(Rational(0) >= Rational(0))
    }
}
