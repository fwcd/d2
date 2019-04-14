import D2Utils

struct SumNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	var occurringVariables: [String] { return lhs.occurringVariables + rhs.occurringVariables }
	
	func evaluate(with feedDict: [String: Double]) throws -> Double {
		return (try lhs.evaluate(with: feedDict)) + (try rhs.evaluate(with: feedDict))
	}
}
