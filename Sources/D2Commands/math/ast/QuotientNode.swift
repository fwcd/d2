import D2Utils

struct QuotientNode: ExpressionASTNode {
	let lhs: ExpressionASTNode
	let rhs: ExpressionASTNode
	var isConstant: Bool { return lhs.isConstant && rhs.isConstant }
	
	func evaluate(with feedDict: [String: Double]) throws -> Double {
		let numerator = try lhs.evaluate(with: feedDict)
		let denominator = try rhs.evaluate(with: feedDict)
		guard denominator != 0.0 else { throw ExpressionError.divisionByZero(numerator, denominator) }
		return numerator / denominator
	}
}
