struct D2ScriptExpressionEvaluator: D2ScriptASTVisitor {
	private let storage: D2ScriptStorage
	
	init(storage: D2ScriptStorage) {
		self.storage = storage
	}
	
	func visit(node: D2ScriptASTNode) -> D2ScriptValue? {
		return nil
	}
	
	func visit(value: D2ScriptValue) -> D2ScriptValue? {
		return value
	}
	
	func visit(identifierExpression: D2ScriptIdentifierExpression) -> D2ScriptValue? {
		return storage[identifierExpression.name]
	}
	
	func visit(functionCall: D2ScriptFunctionCall) -> D2ScriptValue? {
		let evaluatedArgs = functionCall.arguments.map { $0.accept(self) }
		return storage[function: functionCall.functionName]?(evaluatedArgs)
	}
}
