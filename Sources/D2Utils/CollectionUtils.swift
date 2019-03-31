public extension Collection {
	subscript(safely index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
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
