public protocol D2ScriptASTNode: Sendable {
    var label: String { get }

    func accept<V: D2ScriptASTVisitor>(_ visitor: V) async -> V.VisitResult

    func isEqual(to node: any D2ScriptASTNode) -> Bool
}

public extension D2ScriptASTNode where Self: Equatable {
    func isEqual(to rhs: any D2ScriptASTNode) -> Bool {
        guard let other = rhs as? Self else { return false }
        return self == other
    }
}
