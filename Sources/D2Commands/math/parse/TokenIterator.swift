/**
 * An iterator wrapper for a sequence of tokens
 * that explicitly uses reference semantics.
 */
class TokenIterator<T>: IteratorProtocol {
	private var iterator: Array<T>.Iterator
	private var lastPeeked: T? = nil
	private(set) var current: T? = nil
	
	init(_ array: [T]) {
		iterator = array.makeIterator()
	}
	
	@discardableResult
	func next() -> T? {
		if let peeked = lastPeeked {
			lastPeeked = nil
			current = peeked
			return peeked
		} else {
			let nextValue = iterator.next()
			current = nextValue
			return nextValue
		}
	}
	
	func peek() -> T? {
		if let peeked = lastPeeked {
			return peeked
		} else {
			lastPeeked = iterator.next()
			return lastPeeked
		}
	}
}
