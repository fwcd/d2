public struct D2ScriptParser {
	func parse(_ input: String) throws -> D2ScriptTopLevelScope {
		return try parse(tokens: try tokenize(input))
	}
	
	func tokenize(_ input: String) throws -> [D2ScriptToken] {
		// TODO
		return []
	}
	
	func parse(tokens: [D2ScriptToken]) throws -> D2ScriptTopLevelScope {
		// TODO
		return D2ScriptTopLevelScope()
	}
}
