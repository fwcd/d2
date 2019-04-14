import D2Utils
import Foundation

struct ExponentiationNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	var occurringVariables: Set<String> { return lhs.occurringVariables.union(rhs.occurringVariables) }
	
	func evaluate(with feedDict: [String: Double]) throws -> Double {
		return pow(try lhs.evaluate(with: feedDict), try rhs.evaluate(with: feedDict))
	}
}
