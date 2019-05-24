public struct D2ScriptIdentifierExpression: D2ScriptExpression {
	public let label = "IdentifierExpression"
	public let identifier: String
	
	public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
		return visitor.visit(identifierExpression: self)
	}
}
