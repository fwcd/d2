import XCTest
@testable import D2Utils

final class Mat2Tests: XCTestCase {
    static var allTests = [
        ("testMat2", testMat2)
    ]
    
    func testMat2() throws {
        let a = Mat2(
            ix:  3, jx: 6,
            iy: -6, jy: 9
        )
        let b = Mat2(
            ix: 1, jx: -2,
            iy: 4, jy:  3
        )
        XCTAssertEqual(a + b, Mat2(
            ix:  4, jx: 4,
            iy: -2, jy: 12
        ))
        XCTAssertEqual(a - b, Mat2(
            ix:  2,  jx: 8,
            iy: -10, jy: 6
        ))
        XCTAssertEqual(a * b, Mat2(
            ix: 27, jx: 12,
            iy: 30, jy: 39
        ))
        XCTAssertEqual(Mat2(
            ix: 1, jx: 1,
            iy: 1, jy: 0
        ).inverse, Mat2(
            ix: 0, jx:  1,
            iy: 1, jy: -1
        ))
        XCTAssertEqual(a * Vec2(x: 4, y: 2), Vec2(x: 24, y: -6))
    }
}
