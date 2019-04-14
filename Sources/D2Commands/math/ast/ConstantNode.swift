import D2Utils

struct ConstantNode: ExpressionASTNode {
	let value: Double
	let occurringVariables: Set<String> = []
	var label: String { return String(value) }
	
	func evaluate(with feedDict: [String: Double]) -> Double { return value }
}
