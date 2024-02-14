import Utils

struct SumNode: ExpressionASTNode {
    let lhs: any ExpressionASTNode
    let rhs: any ExpressionASTNode
    let label: String = "+"
    var occurringVariables: Set<String> { return lhs.occurringVariables.union(rhs.occurringVariables) }
    var childs: [any ExpressionASTNode] { return [lhs, rhs] }

    func evaluate(with feedDict: [String: Double]) throws -> Double {
        return (try lhs.evaluate(with: feedDict)) + (try rhs.evaluate(with: feedDict))
    }
}
