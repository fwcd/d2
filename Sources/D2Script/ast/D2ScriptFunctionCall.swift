public struct D2ScriptFunctionCall: D2ScriptExpression, Equatable {
    public let label = "FunctionCall"
    public let functionName: String
    public let arguments: [D2ScriptExpression]

    public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
        return visitor.visit(functionCall: self)
    }

    public static func ==(lhs: D2ScriptFunctionCall, rhs: D2ScriptFunctionCall) -> Bool {
        return lhs.functionName == rhs.functionName && !zip(lhs.arguments, rhs.arguments).contains { !$0.isEqual(to: $1) }
    }
}
