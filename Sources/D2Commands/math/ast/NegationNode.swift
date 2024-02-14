import Utils

struct NegationNode: ExpressionASTNode, Equatable {
    let operand: any ExpressionASTNode
    let label: String = "-"
    var occurringVariables: Set<String> { return operand.occurringVariables }
    var childs: [any ExpressionASTNode] { return [operand] }

    func evaluate(with feedDict: [String: Double]) throws -> Double {
        return -(try operand.evaluate(with: feedDict))
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.operand.isEqual(to: rhs.operand)
    }
}
