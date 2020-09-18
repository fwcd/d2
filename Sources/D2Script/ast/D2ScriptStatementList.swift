public struct D2ScriptStatementList: D2ScriptASTNode, Equatable {
    public let label = "StatementList"
    public let statements: [D2ScriptStatement]

    public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
        return visitor.visit(statementList: self)
    }

    public static func ==(lhs: D2ScriptStatementList, rhs: D2ScriptStatementList) -> Bool {
        return !zip(lhs.statements, rhs.statements).contains { !$0.isEqualTo($1) }
    }
}
