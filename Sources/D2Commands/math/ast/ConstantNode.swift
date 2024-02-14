import Foundation
import Utils

struct ConstantNode: ExpressionASTNode, Equatable {
    let value: Double
    let occurringVariables: Set<String> = []
    var label: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        formatter.numberStyle = .decimal
        return formatter.string(from: value as NSNumber) ?? String(value)
    }
    var prefixFunctionNotation: String { return label }
    var infixICNotation: String { return label }

    func evaluate(with feedDict: [String: Double]) -> Double { return value }
}
