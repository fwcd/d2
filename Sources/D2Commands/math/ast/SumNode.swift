import D2Utils

struct SumNode<T: Addable> {
	let lhs: T
	let rhs: T
	
	var value: T { return lhs + rhs }
}
