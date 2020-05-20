/**
 * A higher-order function that produces an ascending comparator
 * (as used by sorted(by:)) comparing a specific property.
 */
public func ascendingComparator<T, P>(comparing property: @escaping (T) -> P) -> (T, T) -> Bool
	where P: Comparable {
    { property($0) < property($1) }
}

/**
 * A higher-order function that produces an ascending comparator
 * (as used by sorted(by:)) comparing a specific property.
 */
public func ascendingComparator<T, P, R>(comparing property: @escaping (T) -> P, then inner: @escaping (T) -> R) -> (T, T) -> Bool
	where P: Equatable & Comparable, R: Comparable {
	{
		let p0 = property($0)
		let p1 = property($1)
		return p0 == p1 ? (inner($0) < inner($1)) : (p0 < p1)
	}
}

/**
 * A higher-order function that produces a descending comparator
 * (as used by sorted(by:)) comparing two specific properties lexicographically.
 */
public func descendingComparator<T, P>(comparing property: @escaping (T) -> P) -> (T, T) -> Bool
	where P: Comparable {
    { property($0) > property($1) }
}

/**
 * A higher-order function that produces a descending comparator
 * (as used by sorted(by:)) comparing two specific properties lexicographically.
 */
public func descendingComparator<T, P, R>(comparing property: @escaping (T) -> P, then inner: @escaping (T) -> R) -> (T, T) -> Bool
	where P: Equatable & Comparable, R: Comparable {
	{
		let p0 = property($0)
		let p1 = property($1)
		return p0 == p1 ? (inner($0) > inner($1)) : (p0 > p1)
	}
}
