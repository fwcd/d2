public struct D2ScriptAssignment: D2ScriptStatement {
	public let label = "Assignment"
	public let identifier: String
	public let expression: D2ScriptExpression
}
