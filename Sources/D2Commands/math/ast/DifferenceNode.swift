import D2Utils

struct DifferenceNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	let label: String = "-"
	var occurringVariables: Set<String> { return lhs.occurringVariables.union(rhs.occurringVariables) }
	var childs: [ExpressionASTNode] { return [lhs, rhs] }
	
	func evaluate(with feedDict: [String: Double]) throws -> Double {
		return (try lhs.evaluate(with: feedDict)) - (try rhs.evaluate(with: feedDict))
	}
}
