public struct D2ScriptExpressionStatement: D2ScriptStatement {
	public let label = "ExpressionStatement"
	public let expression: D2ScriptExpression
	
	public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
		return visitor.visit(expressionStatement: self)
	}
}
