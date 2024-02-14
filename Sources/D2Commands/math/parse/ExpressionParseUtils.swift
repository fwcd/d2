let expressionBinaryOperators: [String: BinaryOperatorEntry] = [
    "+": BinaryOperatorEntry(precedence: 1, associativity: .left) { SumNode(lhs: $0, rhs: $1) },
    "-": BinaryOperatorEntry(precedence: 1, associativity: .left) { DifferenceNode(lhs: $0, rhs: $1) },
    "*": BinaryOperatorEntry(precedence: 2, associativity: .left) { ProductNode(lhs: $0, rhs: $1) },
    "/": BinaryOperatorEntry(precedence: 2, associativity: .left) { QuotientNode(lhs: $0, rhs: $1) },
    "^": BinaryOperatorEntry(precedence: 3, associativity: .right) { ExponentiationNode(lhs: $0, rhs: $1) }
]

let expressionUnaryOperators: [String: UnaryOperatorEntry] = [
    "-": UnaryOperatorEntry(position: .prefixPosition) { NegationNode(value: $0) }
]

let expressionConstants: [String: any ExpressionASTNode] = [
    "e": ConstantNode(value: 2.71828182845904523536),
    "pi": ConstantNode(value: .pi)
]

let allExpressionOperators: Set<String> = Set(expressionUnaryOperators.keys).union(Set(expressionBinaryOperators.keys))

let integerVariableNames: Set<String> = ["n", "m", "k"]
