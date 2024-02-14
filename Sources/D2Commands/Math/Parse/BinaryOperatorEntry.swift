struct BinaryOperatorEntry {
    let precedence: Int
    let associativity: Associativity
    let factory: (any ExpressionASTNode, any ExpressionASTNode) -> any ExpressionASTNode
}
