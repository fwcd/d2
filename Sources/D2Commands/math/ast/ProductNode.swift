import D2Utils

struct ProductNode<T: Multipliable> {
	let lhs: T
	let rhs: T
	
	var value: T { return lhs * rhs }
}
