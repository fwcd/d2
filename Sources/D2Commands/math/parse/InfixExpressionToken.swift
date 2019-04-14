enum InfixExpressionToken: Hashable {
	case number(Double)
	case identifier(String)
	case binaryOperator(String)
	case openingParenthesis
	case closingParenthesis
}
