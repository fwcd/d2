/**
 * A higher-order function that produces a comparator
 * (as used by sorted(by:)) comparing a specific property.
 */
public func comparator<T, P: Comparable>(comparing property: @escaping (T) -> P) -> ((T, T) -> Bool) {
	return { property($0) < property($1) }
}
