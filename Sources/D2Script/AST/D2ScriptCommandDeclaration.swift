public struct D2ScriptCommandDeclaration: D2ScriptASTNode, Equatable {
    public let label = "CommandDeclaration"
    public let commandName: String
    public let statementList: D2ScriptStatementList

    public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
        return visitor.visit(commandDeclaration: self)
    }
}
