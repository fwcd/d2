import XCTest
@testable import D2Commands

final class ExpressionParserTests: XCTestCase {
	static var allTests = [
		("testRPNExpressionParser", testRPNExpressionParser)
	]
	
	private func testRPNExpressionParser() throws {
		let eps = 0.00001
		let parser = RPNExpressionParser()
		
		let rawProduct = "3 4 *"
		guard let product = try parser.parse(rawProduct) as? ProductNode else { XCTFail("\(rawProduct) should be a product node"); return }
		XCTAssertEqual(try product.lhs.evaluate(), 3.0, accuracy: eps)
		XCTAssertEqual(try product.rhs.evaluate(), 4.0, accuracy: eps)
		
		let rawQuotient = "2.1 -51.09 pi + 1   -  /"
		guard let quotient = try parser.parse(rawQuotient) as? QuotientNode else { XCTFail("\(rawQuotient) should be a quotient node"); return }
		guard let quotientLeft = quotient.lhs as? ConstantNode else { XCTFail("Left-hand side of quotient should be a constant"); return }
		guard let quotientRight = quotient.rhs as? DifferenceNode else { XCTFail("Right-hand side of quotient should be a difference"); return }
		guard let differenceLeft = quotientRight.lhs as? SumNode else { XCTFail("Left-hand side of difference should be a sum"); return }
		guard let differenceRight = quotientRight.rhs as? ConstantNode else { XCTFail("Right-hand side of quotient should be a constant"); return }
		guard let sumLeft = differenceLeft.lhs as? ConstantNode else { XCTFail("Left-hand side of sum should be a constant"); return }
		guard let sumRight = differenceLeft.rhs as? ConstantNode else { XCTFail("Right-hand side of sum should be a constant"); return }
		XCTAssertEqual(try quotientLeft.evaluate(), 2.1, accuracy: eps)
		XCTAssertEqual(try sumLeft.evaluate(), -51.09, accuracy: eps)
		XCTAssertEqual(try sumRight.evaluate(), Double.pi, accuracy: eps)
		XCTAssertEqual(try differenceRight.evaluate(), 1.0, accuracy: eps)
	}
}
