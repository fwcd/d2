import Utils

struct NegationNode: ExpressionASTNode {
    let value: any ExpressionASTNode
    let label: String = "-"
    var occurringVariables: Set<String> { return value.occurringVariables }
    var childs: [any ExpressionASTNode] { return [value] }

    func evaluate(with feedDict: [String: Double]) throws -> Double {
        return -(try value.evaluate(with: feedDict))
    }
}
