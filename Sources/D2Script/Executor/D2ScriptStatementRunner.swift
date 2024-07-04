struct D2ScriptStatementRunner: D2ScriptASTVisitor {
    private let storage: D2ScriptStorage
    private let evaluator: D2ScriptExpressionEvaluator

    init(storage: D2ScriptStorage) {
        self.storage = storage
        evaluator = D2ScriptExpressionEvaluator(storage: storage)
    }

    func visit(script: D2Script) async {
        for node in script.topLevelNodes {
            await node.accept(self)
        }
    }

    func visit(statementList: D2ScriptStatementList) async {
        for statement in statementList.statements {
            await statement.accept(self)
        }
    }

    func visit(expressionStatement: D2ScriptExpressionStatement) async {
        _ = await expressionStatement.expression.accept(evaluator)
    }

    func visit(assignment: D2ScriptAssignment) async {
        storage[assignment.identifier] = await assignment.expression.accept(evaluator)
    }

    func visit(commandDeclaration: D2ScriptCommandDeclaration) async {
        let parentStorage = storage
        storage[function: commandDeclaration.commandName] = { (args: [D2ScriptValue?]) -> D2ScriptValue? in
            await commandDeclaration.statementList.accept(D2ScriptStatementRunner(storage: D2ScriptStorage(name: "\(commandDeclaration.commandName) locals", parent: parentStorage)))
            return nil
        }
        storage.register(commandName: commandDeclaration.commandName)
    }
}
