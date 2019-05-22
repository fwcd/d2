public struct D2ScriptStatementList: D2ScriptASTNode {
	public let label = "StatementList"
	public let statements: [D2ScriptStatement]
	
	public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
		return visitor.visit(statementList: self)
	}
}
