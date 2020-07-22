/// An iterator wrapper for a sequence of tokens
/// that explicitly uses reference semantics.
public class TokenIterator<T>: IteratorProtocol {
	private var iterator: Array<T>.Iterator
	private var lookahead: [T] = []
	public private(set) var current: T? = nil
	
	public init(_ array: [T]) {
		iterator = array.makeIterator()
	}
	
	@discardableResult
	public func next() -> T? {
		if let peeked = lookahead.first {
			lookahead.removeFirst()
			return peeked
		} else {
			let nextValue = iterator.next()
			current = nextValue
			if !lookahead.isEmpty {
				lookahead.removeFirst()
			}
			return nextValue
		}
	}
	
	/// Peeks the kth token (if it exists).
	public func peek(_ k: Int = 1) -> T? {
		guard k >= 1 else { return nil }
		
		if let peeked = lookahead[safely: k - 1] {
			return peeked
		} else {
			while lookahead.count < k {
				if let nextElement = iterator.next() {
					lookahead.append(nextElement)
				} else {
					break
				}
			}
			return lookahead[safely: k - 1]
		}
	}

	/// Finds the first matching token in the rest of the
	/// array without advancing the iteration. This allows users
	/// to essentially do 'infinite lookahead'. Note that this will also
	/// extend the internal lookahead buffer.
	public func first(where predicate: (T) -> Bool) -> T? {
		var i = 1
		while let token = peek(i) {
			if predicate(token) {
				return token
			}
			i += 1
		}
		return nil
	}

	public func contains(where predicate: (T) -> Bool) -> Bool {
		first(where: predicate) != nil
	}
}
