import Utils

struct FloorNode: ExpressionASTNode {
    let operand: any ExpressionASTNode
    let label: String = "floor"
    var occurringVariables: Set<String> { return operand.occurringVariables }
    var childs: [any ExpressionASTNode] { return [operand] }

    func evaluate(with feedDict: [String: Double]) throws -> Double {
        return try operand.evaluate(with: feedDict).rounded(.down)
    }
}
