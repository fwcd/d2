public protocol D2ScriptASTVisitor {
    associatedtype VisitResult = Void

    /// Visits an unspecified node. This is the
    /// only required method if VisitResult != Void
    /// (otherwise no methods are required).
    func visit(node: D2ScriptASTNode) -> VisitResult

    // Expressions

    func visit(expression: D2ScriptExpression) -> VisitResult

    func visit(functionCall: D2ScriptFunctionCall) -> VisitResult

    func visit(value: D2ScriptValue) -> VisitResult

    func visit(identifierExpression: D2ScriptIdentifierExpression) -> VisitResult

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
    func visit(node: D2ScriptASTNode) -> VisitResult {}
}

public extension D2ScriptASTVisitor {
    func visit(script: D2Script) -> VisitResult { return visit(node: script) }

    func visit(expression: D2ScriptExpression) -> VisitResult { return visit(node: expression) }

    func visit(statement: D2ScriptStatement) -> VisitResult { return visit(node: statement) }

    func visit(commandDeclaration: D2ScriptCommandDeclaration) -> VisitResult { return visit(node: commandDeclaration) }

    func visit(statementList: D2ScriptStatementList) -> VisitResult { return visit(node: statementList) }

    // Expressions

    func visit(functionCall: D2ScriptFunctionCall) -> VisitResult { return visit(expression: functionCall) }

    func visit(value: D2ScriptValue) -> VisitResult { return visit(expression: value) }

    func visit(identifierExpression: D2ScriptIdentifierExpression) -> VisitResult { return visit(expression: identifierExpression) }

    // Statements

    func visit(expressionStatement: D2ScriptExpressionStatement) -> VisitResult { return visit(statement: expressionStatement) }

    func visit(assignment: D2ScriptAssignment) -> VisitResult { return visit(statement: assignment) }
}
