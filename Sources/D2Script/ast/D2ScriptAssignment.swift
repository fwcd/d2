public struct D2ScriptAssignment: D2ScriptStatement {
	public let label = "Assignment"
	public let identifier: String
	public let expression: D2ScriptExpression
	
	public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
		return visitor.visit(assignment: self)
	}
}
