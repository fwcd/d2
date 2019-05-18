public struct D2ScriptFunctionCall: D2ScriptExpression {
	public let label = "FunctionCall" // TODO
	public let functionName: String
	public let arguments: [D2ScriptValue]
}
