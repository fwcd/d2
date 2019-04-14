import D2Utils

struct FloorNode: ExpressionASTNode {
	let value: ExpressionASTNode
	var occurringVariables: [String] { return value.occurringVariables }
	
	func evaluate(with feedDict: [String: Double]) throws -> Double {
		return try value.evaluate(with: feedDict).rounded(.down)
	}
}
