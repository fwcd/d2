public struct D2ScriptStatementList: D2ScriptASTNode, Equatable {
    public let label = "StatementList"
    public let statements: [D2ScriptStatement]

    public func accept<V: D2ScriptASTVisitor>(_ visitor: V) async -> V.VisitResult {
        return await visitor.visit(statementList: self)
    }

    public static func ==(lhs: D2ScriptStatementList, rhs: D2ScriptStatementList) -> Bool {
        return !zip(lhs.statements, rhs.statements).contains { !$0.isEqual(to: $1) }
    }
}
