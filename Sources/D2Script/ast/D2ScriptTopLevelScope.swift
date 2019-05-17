public struct D2ScriptTopLevelScope: D2ScriptASTNode {
	public let label = "TopLevelScope"
	public internal(set) var childs: [D2ScriptASTNode] = []
}
