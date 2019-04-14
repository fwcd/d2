import D2Utils

struct ConstantNode: ExpressionASTNode {
	let value: Double
	let occurringVariables: Set<String> = []
	
	func evaluate(with feedDict: [String: Double]) -> Double { return value }
}
