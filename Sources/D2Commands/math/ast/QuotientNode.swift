import D2Utils

struct QuotientNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	
	var value: Double { return lhs.value / rhs.value }
}
