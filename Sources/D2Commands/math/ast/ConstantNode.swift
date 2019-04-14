import D2Utils

struct ConstantNode: ExpressionASTNode {
	let value: Double
	let occurringVariables: [String] = []
	
	func evaluate(with feedDict: [String: Double]) -> Double { return value }
}
