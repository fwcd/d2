public struct D2ScriptCommandDeclaration: D2ScriptASTNode {
	public let label = "CommandDeclaration"
	public let commandName: String
	public let statementList: D2ScriptStatementList
}
