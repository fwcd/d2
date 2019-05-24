public struct D2ScriptAssignment: D2ScriptStatement, Equatable {
	public let label = "Assignment"
	public let identifier: String
	public let expression: D2ScriptExpression
	
	public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
		return visitor.visit(assignment: self)
	}
	
	public static func ==(lhs: D2ScriptAssignment, rhs: D2ScriptAssignment) -> Bool {
		return lhs.label == rhs.label && lhs.expression.isEqualTo(rhs.expression)
	}
}
