public protocol D2ScriptASTVisitor {
    associatedtype VisitResult = Void

    /// Visits an unspecified node. This is the
    /// only required method if VisitResult != Void
    /// (otherwise no methods are required).
    func visit(node: D2ScriptASTNode) async -> VisitResult

    // Expressions

    func visit(expression: D2ScriptExpression) async -> VisitResult

    func visit(functionCall: D2ScriptFunctionCall) async -> VisitResult

    func visit(value: D2ScriptValue) async -> VisitResult

    func visit(identifierExpression: D2ScriptIdentifierExpression) async -> VisitResult

    // Statements

    func visit(statement: D2ScriptStatement) async -> VisitResult

    func visit(assignment: D2ScriptAssignment) async -> VisitResult

    func visit(expressionStatement: D2ScriptExpressionStatement) async -> VisitResult

    // Others

    func visit(script: D2Script) async -> VisitResult

    func visit(commandDeclaration: D2ScriptCommandDeclaration) async -> VisitResult

    func visit(statementList: D2ScriptStatementList) async -> VisitResult
}

public extension D2ScriptASTVisitor where Self.VisitResult == Void {
    func visit(node: D2ScriptASTNode) -> Void {}
}

public extension D2ScriptASTVisitor {
    func visit(script: D2Script) async -> VisitResult { await visit(node: script) }

    func visit(expression: D2ScriptExpression) async -> VisitResult { await visit(node: expression) }

    func visit(statement: D2ScriptStatement) async -> VisitResult { await visit(node: statement) }

    func visit(commandDeclaration: D2ScriptCommandDeclaration) async -> VisitResult { await visit(node: commandDeclaration) }

    func visit(statementList: D2ScriptStatementList) async -> VisitResult { await visit(node: statementList) }

    // Expressions

    func visit(functionCall: D2ScriptFunctionCall) async -> VisitResult { await visit(expression: functionCall) }

    func visit(value: D2ScriptValue) async -> VisitResult { await visit(expression: value) }

    func visit(identifierExpression: D2ScriptIdentifierExpression) async -> VisitResult { await visit(expression: identifierExpression) }

    // Statements

    func visit(expressionStatement: D2ScriptExpressionStatement) async -> VisitResult { await visit(statement: expressionStatement) }

    func visit(assignment: D2ScriptAssignment) async -> VisitResult { await visit(statement: assignment) }
}
