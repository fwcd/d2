public protocol D2ScriptASTNode {
    var label: String { get }

    func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult

    func isEqualTo(_ node: D2ScriptASTNode) -> Bool
}

public extension D2ScriptASTNode where Self: Equatable {
    func isEqualTo(_ rhs: D2ScriptASTNode) -> Bool {
        guard let other = rhs as? Self else { return false }
        return self == other
    }
}
