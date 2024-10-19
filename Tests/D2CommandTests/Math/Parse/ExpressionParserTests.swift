import Testing
import D2TestUtils
@testable import D2Commands

struct ExpressionParserTests {
    @Test func rpnExpressionParser() throws {
        let parser = RPNExpressionParser()

        let rawProduct = "3 4 *"
        guard let product = try parser.parse(rawProduct) as? ProductNode else { Issue.record("\(rawProduct) should be a product node"); return }
        #expect(try product.lhs.evaluate().isApproximatelyEqual(to: 3.0))
        #expect(try product.rhs.evaluate().isApproximatelyEqual(to: 4.0))

        let rawQuotient = "2.1 -51.09 pi + 1   -  /"
        guard let quotient = try parser.parse(rawQuotient) as? QuotientNode else { Issue.record("\(rawQuotient) should be a quotient node"); return }
        guard let quotientLeft = quotient.lhs as? ConstantNode else { Issue.record("Left-hand side of quotient should be a constant"); return }
        guard let quotientRight = quotient.rhs as? DifferenceNode else { Issue.record("Right-hand side of quotient should be a difference"); return }
        guard let differenceLeft = quotientRight.lhs as? SumNode else { Issue.record("Left-hand side of difference should be a sum"); return }
        guard let differenceRight = quotientRight.rhs as? ConstantNode else { Issue.record("Right-hand side of quotient should be a constant"); return }
        guard let sumLeft = differenceLeft.lhs as? ConstantNode else { Issue.record("Left-hand side of sum should be a constant"); return }
        guard let sumRight = differenceLeft.rhs as? ConstantNode else { Issue.record("Right-hand side of sum should be a constant"); return }
        #expect(try quotientLeft.evaluate().isApproximatelyEqual(to: 2.1))
        #expect(try sumLeft.evaluate().isApproximatelyEqual(to: -51.09))
        #expect(try sumRight.evaluate().isApproximatelyEqual(to: Double.pi))
        #expect(try differenceRight.evaluate().isApproximatelyEqual(to: 1.0))
    }

    @Test func infixExpressionParser() throws {
        let parser = InfixExpressionParser()

        #expect(try parser.parse("3 * 4").isEqual(to: ProductNode(lhs: ConstantNode(value: 3), rhs: ConstantNode(value: 4))))
        #expect(try parser.parse("3 + 4").isEqual(to: SumNode(lhs: ConstantNode(value: 3), rhs: ConstantNode(value: 4))))
        #expect(try parser.parse("4 - 9 * 8").isEqual(to: DifferenceNode(lhs: ConstantNode(value: 4), rhs: ProductNode(lhs: ConstantNode(value: 9), rhs: ConstantNode(value: 8)))))
        #expect(try parser.parse("(4 - 9) * 8").isEqual(to: ProductNode(lhs: DifferenceNode(lhs: ConstantNode(value: 4), rhs: ConstantNode(value: 9)), rhs: ConstantNode(value: 8))))
    }
}
