enum ExpressionError: Error {
	case invalidOperator(String)
	case tooFewOperands(String)
	case noValueForPlaceholder(String)
	case divisionByZero(Double, Double)
	case unhandledToken(String)
	case emptyResult
}
