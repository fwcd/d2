import D2Utils

struct ConstantNode: ExpressionASTNode {
	let value: Double
	
	func evaluate(with feedDict: [String: Double]) -> Double { return value }
}
