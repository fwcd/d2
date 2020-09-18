public struct D2Script: D2ScriptASTNode, Equatable {
    public let label = "Script"
    public let topLevelNodes: [D2ScriptASTNode]

    public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
        return visitor.visit(script: self)
    }

    public static func ==(lhs: D2Script, rhs: D2Script) -> Bool {
        return lhs.label == rhs.label && !zip(lhs.topLevelNodes, rhs.topLevelNodes).contains { !$0.isEqualTo($1) }
    }
}
