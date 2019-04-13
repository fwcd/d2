import D2Utils
import Foundation

struct ExponentiationNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	var isConstant: Bool { return lhs.isConstant && rhs.isConstant }
	
	func evaluate(with feedDict: [String: Double]) throws -> Double {
		return pow(try lhs.evaluate(with: feedDict), try rhs.evaluate(with: feedDict))
	}
}
