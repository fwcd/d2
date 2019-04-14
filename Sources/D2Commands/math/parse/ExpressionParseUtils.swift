let expressionBinaryOperators: [String: (ExpressionASTNode, ExpressionASTNode) -> ExpressionASTNode] = [
	"+": { SumNode(lhs: $0, rhs: $1) },
	"-": { DifferenceNode(lhs: $0, rhs: $1) },
	"*": { ProductNode(lhs: $0, rhs: $1) },
	"/": { QuotientNode(lhs: $0, rhs: $1) },
	"^": { ExponentiationNode(lhs: $0, rhs: $1) }
]

let expressionConstants: [String: ExpressionASTNode] = [
	"e": ConstantNode(value: 2.71828182845904523536),
	"pi": ConstantNode(value: .pi)
]

let integerVariableNames: Set<String> = ["n", "m", "k"]
