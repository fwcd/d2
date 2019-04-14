let expressionBinaryOperators: [String: BinaryOperatorEntry] = [
	"+": BinaryOperatorEntry(precedence: 1, associativity: .left) { SumNode(lhs: $0, rhs: $1) },
	"-": BinaryOperatorEntry(precedence: 1, associativity: .left) { DifferenceNode(lhs: $0, rhs: $1) },
	"*": BinaryOperatorEntry(precedence: 2, associativity: .left) { ProductNode(lhs: $0, rhs: $1) },
	"/": BinaryOperatorEntry(precedence: 2, associativity: .left) { QuotientNode(lhs: $0, rhs: $1) },
	"^": BinaryOperatorEntry(precedence: 3, associativity: .right) { ExponentiationNode(lhs: $0, rhs: $1) }
]

let expressionConstants: [String: ExpressionASTNode] = [
	"e": ConstantNode(value: 2.71828182845904523536),
	"pi": ConstantNode(value: .pi)
]

let integerVariableNames: Set<String> = ["n", "m", "k"]
