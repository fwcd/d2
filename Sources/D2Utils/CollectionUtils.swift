public extension Collection {
	subscript(safely index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

public extension Array {
	func truncate(_ length: Int) -> [Element] {
		if count > length {
			return Array(prefix(length))
		} else {
			return self
		}
	}
	
	func chunks(ofLength chunkLength: Int) -> [[Element]] {
		return stride(from: 0, to: count, by: chunkLength).map { Array(self[$0..<Swift.min($0 + chunkLength, count)]) }
	}
}

public extension Array where Element: Equatable {
	func allIndices(of element: Element) -> [Index] {
		return enumerated().filter { $0.1 == element }.map { $0.0 }
	}
	
	@discardableResult
	mutating func removeFirst(value: Element) -> Element? {
		guard let index = firstIndex(of: value) else { return nil }
		return remove(at: index)
	}
}
