/**
 * A higher-order function that produces an ascending comparator
 * (as used by sorted(by:)) comparing a specific property.
 */
public func ascendingComparator<T, P: Comparable>(comparing property: @escaping (T) -> P) -> ((T, T) -> Bool) {
	return { property($0) < property($1) }
}

/**
 * A higher-order function that produces an descending comparator
 * (as used by sorted(by:)) comparing a specific property.
 */
public func descendingComparator<T, P: Comparable>(comparing property: @escaping (T) -> P) -> ((T, T) -> Bool) {
	return { property($0) > property($1) }
}
