import XCTest
@testable import D2Utils

fileprivate let eps = 0.0001

final class MatrixTests: XCTestCase {
    static var allTests = [
        ("testMinor", testMinor),
        ("testDeterminant", testDeterminant),
        ("testRowEcholonForm", testRowEcholonForm),
        ("testInverse", testInverse)
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
        XCTAssertEqual(Matrix<Double>([[-7]]).determinant, -7)
        XCTAssertEqual(Matrix<Rational>([
            [4, -29, -8],
            [0, -1, 0],
            [0, 0, 2]
        ]).determinant!.asDouble, -8, accuracy: eps)
        XCTAssertEqual(Matrix<Double>([
            [4, 5],
            [-3, 6]
        ]).determinant!, 39, accuracy: eps)
        XCTAssertEqual(Matrix<Double>([
            [0, 0],
            [0, 0]
        ]).determinant!, 0, accuracy: eps)
        XCTAssertEqual(Matrix<Double>([
            [1, 0],
            [0, 0]
        ]).determinant!, 0, accuracy: eps)
        XCTAssertEqual(Matrix<Double>([
            [4, 3, 5, 7],
            [1, 2, 3, 4],
            [3, 3, 3, 3],
            [9, 7, 8, 6]
        ]).determinant!, 27, accuracy: eps)
        XCTAssertEqual(Matrix<Int>([
            [4, 3, 5, 7],
            [1, 2, 3, 4],
            [3, 3, 3, 3],
            [9, 7, 8, 6]
        ]).laplaceExpansionDeterminant, 27)
    }

    func testRowEcholonForm() throws {
        assertApproxEqual(Matrix<Double>([
            [1, 3, 1],
            [1, 1, -1],
            [3, 11, 5]
        ]).rowEcholonForm!, Matrix<Double>([
            [1, 3, 1],
            [0, -2, -2],
            [0, 0, 0]
        ]))
    }

    func testInverse() throws {
        XCTAssertEqual(Matrix<Rational>([
            [1, 0, 0],
            [0, 2, 0],
            [0, 0, 3]
        ]).inverse, Matrix<Rational>([
            [1, 0, 0],
            [0, Rational(1, 2), 0],
            [0, 0, Rational(1, 3)]
        ]))
        XCTAssertEqual(Matrix<Rational>([
            [2, 8],
            [8, 4]
        ]).inverse, Matrix<Rational>([
            [-Rational(1, 14), Rational(1, 7)],
            [Rational(1, 7), -Rational(1, 28)]
        ]))
        XCTAssertEqual(Matrix<Rational>([
            [2, 3, 4],
            [8, 9, 5],
            [3, 4, 4]
        ]).inverse, Matrix<Rational>([
            [16, 4, -21],
            [-17, -4, 22],
            [5, 1, -6]
        ]))
        XCTAssertEqual(Matrix<Rational>([
            [2, 3, 4, 6],
            [8, 9, 5, 3],
            [3, 4, 4, -2],
            [1, 0, 2, 3]
        ]).inverse, Rational(1, 237) * Matrix<Rational>([
            [-108, 48, -27, 150],
            [79, 0, 0, -158],
            [15, -33, 63, 45],
            [26, 6, -33, -1]
        ]))
        XCTAssertNil(Matrix<Rational>([
            [1, 0],
            [0, 0]
        ]).inverse)
        XCTAssertNil(Matrix<Rational>([
            [1, 2]
        ]).inverse)
    }

    private func assertApproxEqual(_ a: Matrix<Double>, _ b: Matrix<Double>) {
        XCTAssert(a.width == b.width && a.height == b.height)
        for y in 0..<a.height {
            for x in 0..<a.width {
                XCTAssertEqual(a[y, x], b[y, x], accuracy: eps)
            }
        }
    }
}