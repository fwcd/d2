struct BinaryOperatorEntry {
    let precedence: Int
    let associativity: Associativity
    let factory: (ExpressionASTNode, ExpressionASTNode) -> ExpressionASTNode
}
