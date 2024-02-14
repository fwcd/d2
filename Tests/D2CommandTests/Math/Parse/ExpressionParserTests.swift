import XCTest
@testable import D2Commands

fileprivate let eps = 0.00001

final class ExpressionParserTests: XCTestCase {
    func testRPNExpressionParser() throws {
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

    func testInfixExpressionParser() throws {
        let parser = InfixExpressionParser()

        XCTAssertTrue(try parser.parse("3 * 4").isEqual(to: ProductNode(lhs: ConstantNode(value: 3), rhs: ConstantNode(value: 4))))
        XCTAssertTrue(try parser.parse("3 + 4").isEqual(to: SumNode(lhs: ConstantNode(value: 3), rhs: ConstantNode(value: 4))))
        XCTAssertTrue(try parser.parse("4 - 9 * 8").isEqual(to: DifferenceNode(lhs: ConstantNode(value: 4), rhs: ProductNode(lhs: ConstantNode(value: 9), rhs: ConstantNode(value: 8)))))
        XCTAssertTrue(try parser.parse("(4 - 9) * 8").isEqual(to: ProductNode(lhs: DifferenceNode(lhs: ConstantNode(value: 4), rhs: ConstantNode(value: 9)), rhs: ConstantNode(value: 8))))
    }
}
