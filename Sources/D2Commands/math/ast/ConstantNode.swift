import D2Utils

struct ConstantNode: ExpressionASTNode {
	let value: Double
	let isConstant = true
	
	func evaluate(with feedDict: [String: Double]) -> Double { return value }
}
