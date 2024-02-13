import D2Script

struct DescribingASTVisitor: D2ScriptASTVisitor {
    typealias VisitResult = String

    func visit(statement: D2ScriptStatement) -> String {
        return "Found a statement"
    }

    func visit(functionCall: D2ScriptFunctionCall) -> String {
        return "Found a function call"
    }

    func visit(script: D2Script) -> String {
        return "Found a script"
    }

    func visit(node: D2ScriptASTNode) -> String {
        return "Found unrecognized node"
    }
}
