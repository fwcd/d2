import XCTest
@testable import D2Utils

final class ComplexTests: XCTestCase {
	static var allTests = [
		("testComplex", testComplex)
	]
	private let eps: Double = 0.001
	
	func testComplex() throws {
		let a: Complex = 3 + 4 * .i
		let b: Complex = -5.3 - .i
		
		assertComplexEq(a * b, -11.9 - 24.2 * .i)
		assertComplexEq(a + b, -2.3 + 3 * .i)
		assertComplexEq(a / b, -0.684083878 - 0.625644551 * .i)
		assertComplexEq(a - b, 8.3 + 5 * .i)
		assertComplexEq(-a, -3 - 4 * .i)
	}
	
	private func assertComplexEq(_ lhs: Complex, _ rhs: Complex) {
		XCTAssertEqual(lhs.real, rhs.real, accuracy: eps, "Re(\(lhs)) does not equal Re(\(rhs))")
		XCTAssertEqual(lhs.imag, rhs.imag, accuracy: eps, "Im(\(lhs)) does not equal Im(\(rhs))")
	}
}
