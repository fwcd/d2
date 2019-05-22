public struct D2Script: D2ScriptASTNode {
	public let label = "Script"
	public let topLevelNodes: [D2ScriptASTNode]
	
	public func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult {
		return visitor.visit(script: self)
	}
}
