enum BFError: Error {
	case parenthesesMismatch(String)
	case multiplicationOverflow(Int32, Int32)
	case incrementOverflow(Int32)
	case decrementOverflow(Int32)
	case addressOverflow(Int32)
}
