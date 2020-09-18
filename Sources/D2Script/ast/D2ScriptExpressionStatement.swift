public struct D2ScriptExpressionStatement: D2ScriptStatement, Equatable {
    public let label = "ExpressionStatement"
    public let expression: D2ScriptExpression

    public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
        return visitor.visit(expressionStatement: self)
    }

    public static func ==(lhs: D2ScriptExpressionStatement, rhs: D2ScriptExpressionStatement) -> Bool {
        return lhs.expression.isEqualTo(rhs.expression)
    }
}
