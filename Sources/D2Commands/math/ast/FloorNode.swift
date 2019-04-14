import D2Utils

struct FloorNode: ExpressionASTNode {
	let value: ExpressionASTNode
	var occurringVariables: Set<String> { return value.occurringVariables }
	let label: String = "floor"
	
	func evaluate(with feedDict: [String: Double]) throws -> Double {
		return try value.evaluate(with: feedDict).rounded(.down)
	}
}
