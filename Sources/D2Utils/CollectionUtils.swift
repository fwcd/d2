public extension Sequence {
    func count(forWhich predicate: (Element) -> Bool) -> Int {
		// TODO: Implemented in https://github.com/apple/swift-evolution/blob/master/proposals/0220-count-where.md
        return reduce(0) { predicate($1) ? $0 + 1 : $0 }
    }
}

public extension Dictionary where Key: StringProtocol, Value: StringProtocol {
	var urlQueryEncoded: String {
		return map { "\($0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? String($0))=\($1.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? String($1))" }
			.joined(separator: "&")
	}
}

public extension Collection {
	var nilIfEmpty: Self? {
		return isEmpty ? nil : self
	}
	
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

	/// The longest prefix satisfying the predicate and the rest of the list
	func span(_ inPrefix: (Element) -> Bool) -> (ArraySlice<Element>, ArraySlice<Element>) {
		let pre = prefix(while: inPrefix)
		let rest = self[pre.endIndex...]
		return (pre, rest)
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
