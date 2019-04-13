import D2Utils

struct ProductNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	
	var value: Double { return lhs.value * rhs.value }
}
