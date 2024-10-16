public protocol ExpressionASTNode: Sendable {
    var occurringVariables: Set<String> { get }
    var label: String { get }
    var childs: [any ExpressionASTNode] { get }
    var prefixFunctionNotation: String { get }
    var infixICNotation: String { get }

    func evaluate(with feedDict: [String: Double]) throws -> Double

    func isEqual(to rhs: any ExpressionASTNode) -> Bool
}

public extension ExpressionASTNode {
    var isConstant: Bool { return occurringVariables.isEmpty }
    var childs: [any ExpressionASTNode] { return [] }
    var occurringVariables: Set<String> { return Set(childs.flatMap { $0.occurringVariables }) }
    var prefixFunctionNotation: String { return "\(label)(\(childs.map { $0.prefixFunctionNotation }.joined(separator: ",")))" }
    var infixICNotation: String { return "(\(childs.map { $0.infixICNotation }.joined(separator: label)))" }

    func evaluate() throws -> Double {
        return try evaluate(with: [:])
    }
}

public extension ExpressionASTNode where Self: Equatable {
    func isEqual(to rhs: any ExpressionASTNode) -> Bool {
        guard let other = rhs as? Self else { return false }
        return self == other
    }
}
