struct BinaryOperatorEntry: Sendable {
    let precedence: Int
    let associativity: Associativity
    let factory: @Sendable (any ExpressionASTNode, any ExpressionASTNode) -> any ExpressionASTNode
}
