struct UnaryOperatorEntry {
    let position: UnaryOperatorPosition
    let factory: (any ExpressionASTNode) -> any ExpressionASTNode
}
