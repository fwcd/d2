import D2Utils

struct DifferenceNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	
	var value: Double { return lhs.value - rhs.value }
}
