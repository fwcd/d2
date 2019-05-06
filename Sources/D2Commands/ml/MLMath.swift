func heaviside<T: Comparable & ExpressibleByIntegerLiteral>(_ x: T) -> T {
	return (x >= 0) ? 1 : -1
}
