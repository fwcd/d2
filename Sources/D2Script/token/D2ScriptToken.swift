public enum D2ScriptToken: Hashable {
	case identifier(String)
	case keyword(String)
	case stringLiteral(String)
	case numberLiteral(Double)
	case anyOperator(String)
	case leftCurlyBracket
	case rightCurlyBracket
	case leftParenthesis
	case rightParenthesis
	case linebreak
	case comma
}
