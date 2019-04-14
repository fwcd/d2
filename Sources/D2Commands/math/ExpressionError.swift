enum ExpressionError: Error {
	case invalidOperator(String)
	case invalidNumber(String)
	case tooFewOperands(String)
	case noValueForPlaceholder(String)
	case divisionByZero(Double, Double)
	case unrecognizedToken(String)
	case unhandledToken(InfixExpressionToken)
	case parenthesesMismatch(String)
	case unsupported(String)
	case unexpectedEnd
	case emptyResult
}
