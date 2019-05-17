public enum D2ScriptValue: Hashable {
	case string(String)
	case number(Double)
	case map([String: D2ScriptValue])
	case list([D2ScriptValue])
}
