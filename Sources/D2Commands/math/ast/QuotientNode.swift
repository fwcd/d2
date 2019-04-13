import D2Utils

struct QuotientNode<T: Divisible> {
	let lhs: T
	let rhs: T
	
	var value: T { return lhs / rhs }
}
