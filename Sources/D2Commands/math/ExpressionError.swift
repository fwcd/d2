enum ExpressionError: Error {
	case invalidOperator(String)
	case invalidNumber(String)
	case tooFewOperands(String)
	case noValueForPlaceholder(String)
	case divisionByZero(Double, Double)
	case unrecognizedToken(String)
	case unhandledToken(InfixExpressionToken)
	case unexpectedEnd
	case parenthesesMismatch
	case emptyResult
}
