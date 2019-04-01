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

public extension Vec2 where T == Int {
	func isInBounds<T>(of array: [[T]]) -> Bool {
		guard !array.isEmpty else { return false }
		return x >= 0 && y >= 0 && x < array[0].count && y < array.count
	}
}
