import Utils

struct QuotientNode: ExpressionASTNode, Equatable {
    let lhs: any ExpressionASTNode
    let rhs: any ExpressionASTNode
    let label: String = "/"
    var occurringVariables: Set<String> { return lhs.occurringVariables.union(rhs.occurringVariables) }
    var childs: [any ExpressionASTNode] { return [lhs, rhs] }

    func evaluate(with feedDict: [String: Double]) throws -> Double {
        let numerator = try lhs.evaluate(with: feedDict)
        let denominator = try rhs.evaluate(with: feedDict)
        guard denominator != 0.0 else { throw ExpressionError.divisionByZero(numerator, denominator) }
        return numerator / denominator
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.lhs.isEqual(to: rhs.lhs) && lhs.rhs.isEqual(to: rhs.rhs)
    }
}
