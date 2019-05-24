struct D2ScriptExecutingVisitor: D2ScriptASTVisitor {
	private let storage: D2ScriptStorage
	private let evaluator: D2ScriptExpressionEvaluator
	
	init(storage: D2ScriptStorage) {
		self.storage = storage
		evaluator = D2ScriptExpressionEvaluator(storage: storage)
	}
	
	func visit(statementList: D2ScriptStatementList) {
		for statement in statementList.statements {
			statement.accept(self)
		}
	}
	
	func visit(expressionStatement: D2ScriptExpressionStatement) {
		let _ = expressionStatement.expression.accept(evaluator)
	}
	
	func visit(commandDeclaration: D2ScriptCommandDeclaration) {
		let parentStorage = storage
		storage[function: commandDeclaration.commandName] = { (args: [D2ScriptValue?]) -> D2ScriptValue? in
			commandDeclaration.accept(D2ScriptExecutingVisitor(storage: D2ScriptStorage(name: "\(commandDeclaration.commandName) locals", parent: parentStorage)))
			return nil
		}
		storage.register(commandName: commandDeclaration.commandName)
	}
}
