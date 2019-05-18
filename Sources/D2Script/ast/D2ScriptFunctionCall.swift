public struct D2ScriptFunctionCall: D2ScriptExpression {
	public let label = "FunctionCall"
	public let functionName: String
	public let arguments: [D2ScriptExpression]
}
