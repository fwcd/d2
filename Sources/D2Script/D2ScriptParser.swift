public struct D2ScriptParser {
	public func parse(_ input: String) throws -> D2Script {
		return try parse(tokens: try tokenize(input))
	}
	
	private func tokenize(_ input: String) throws -> [D2ScriptToken] {
		// TODO
		return []
	}
	
	private func parse(tokens: [D2ScriptToken]) throws -> D2Script {
		// TODO
		return D2Script()
	}
}
