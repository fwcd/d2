public struct D2Script: D2ScriptASTNode {
	public let label = "Script"
	public internal(set) var childs: [D2ScriptASTNode] = []
}
