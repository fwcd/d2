public protocol D2ScriptASTNode {
	var label: String { get }
	
	func accept<V: D2ScriptASTVisitor>(_ visitor: V) -> V.VisitResult
}
