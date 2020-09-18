struct UnaryOperatorEntry {
    let position: UnaryOperatorPosition
    let factory: (ExpressionASTNode) -> ExpressionASTNode
}
