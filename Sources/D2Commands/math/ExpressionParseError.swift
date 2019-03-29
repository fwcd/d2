enum ExpressionParseError: Error {
	case invalidOperator(String)
	case tooFewOperands(String)
	case emptyResult
}
