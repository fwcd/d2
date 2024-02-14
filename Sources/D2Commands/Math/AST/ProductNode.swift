import Utils

struct ProductNode: ExpressionASTNode, Equatable {
    let lhs: any ExpressionASTNode
    let rhs: any ExpressionASTNode
    let label: String = "*"
    var occurringVariables: Set<String> { return lhs.occurringVariables.union(rhs.occurringVariables) }
    var childs: [any ExpressionASTNode] { return [lhs, rhs] }

    func evaluate(with feedDict: [String: Double]) throws -> Double {
        return (try lhs.evaluate(with: feedDict)) * (try rhs.evaluate(with: feedDict))
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.lhs.isEqual(to: rhs.lhs) && lhs.rhs.isEqual(to: rhs.rhs)
    }
}
