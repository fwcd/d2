public struct D2ScriptIdentifierExpression: D2ScriptExpression, Equatable {
    public let label = "IdentifierExpression"
    public let name: String

    public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
        return visitor.visit(identifierExpression: self)
    }
}
