public struct D2ScriptFunctionCall: D2ScriptExpression {
	public let label = "FunctionCall"
	public let functionName: String
	public let arguments: [D2ScriptExpression]
	
	public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
		return visitor.visit(functionCall: self)
	}
}
