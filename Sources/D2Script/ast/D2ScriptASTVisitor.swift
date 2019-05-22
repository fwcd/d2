public protocol D2ScriptASTVisitor {
	associatedtype VisitResult = Void
	
	// Expressions
	
	func visit(expression: D2ScriptExpression) -> VisitResult
	
	func visit(functionCall: D2ScriptFunctionCall) -> VisitResult
	
	func visit(value: D2ScriptValue) -> VisitResult
	
	// Statements
	
	func visit(statement: D2ScriptStatement) -> VisitResult
	
	func visit(assignment: D2ScriptAssignment) -> VisitResult
	
	func visit(expressionStatement: D2ScriptExpressionStatement) -> VisitResult
	
	// Others
	
	func visit(script: D2Script) -> VisitResult
	
	func visit(commandDeclaration: D2ScriptCommandDeclaration) -> VisitResult
	
	func visit(statementList: D2ScriptStatementList) -> VisitResult
}

public extension D2ScriptASTVisitor where Self.VisitResult == Void {
	func visit(script: D2Script) -> VisitResult {}
	
	func visit(expression: D2ScriptExpression) -> VisitResult {}
	
	func visit(statement: D2ScriptStatement) -> VisitResult {}
	
	func visit(commandDeclaration: D2ScriptFunctionCall) -> VisitResult {}
}

public extension D2ScriptASTVisitor {
	func visit(functionCall: D2ScriptFunctionCall) -> VisitResult { return visit(expression: functionCall) }
	
	func visit(value: D2ScriptValue) -> VisitResult { return visit(expression: value) }
	
	func visit(expressionStatement: D2ScriptExpressionStatement) -> VisitResult { return visit(statement: expressionStatement) }
	
	func visit(assignment: D2ScriptAssignment) -> VisitResult { return visit(statement: assignment) }
}
