import XCTest
@testable import D2Utils

final class MatrixTests: XCTestCase {
    static var allTests = [
        ("testMinor", testMinor),
        ("testDeterminant", testDeterminant)
    ]

    func testMinor() throws {
        XCTAssertEqual(Matrix<Int>([
            [4, 5, 6],
            [7, 8, 9],
            [1, 2, 3]
        ]).minor(0, 0), Matrix<Int>([
            [8, 9],
            [2, 3]
        ]))
        XCTAssertEqual(Matrix<Int>([
            [4, 5, 6],
            [7, 8, 9],
            [1, 2, 3]
        ]).minor(1, 1), Matrix<Int>([
            [4, 6],
            [1, 3]
        ]))
        XCTAssertEqual(Matrix<Int>([
            [4, 5, 6],
            [7, 8, 9],
            [1, 2, 3]
        ]).minor(1, 0), Matrix<Int>([
            [5, 6],
            [2, 3]
        ]))
    }
    
    func testDeterminant() throws {
        XCTAssertEqual(Matrix<Int>([[-7]]).determinant, -7)
        XCTAssertEqual(Matrix<Int>([
            [4, -29, -8],
            [0, -1, 0],
            [0, 0, 2]
        ]).determinant, -8)
        XCTAssertEqual(Matrix<Int>([
            [4, 5],
            [-3, 6]
        ]).determinant, 39)
        XCTAssertEqual(Matrix<Int>([
            [4, 3, 5, 7],
            [1, 2, 3, 4],
            [3, 3, 3, 3],
            [9, 7, 8, 6]
        ]).determinant, 27)
    }
}