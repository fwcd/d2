struct UnaryOperatorEntry: Sendable {
    let position: UnaryOperatorPosition
    let factory: @Sendable (any ExpressionASTNode) -> any ExpressionASTNode
}
