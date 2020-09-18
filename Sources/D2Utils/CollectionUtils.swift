public extension Sequence {
    func count(forWhich predicate: (Element) throws -> Bool) rethrows -> Int {
        // TODO: Implemented in https://github.com/apple/swift-evolution/blob/master/proposals/0220-count-where.md
        try reduce(0) { try predicate($1) ? $0 + 1 : $0 }
    }

    /// Turns a list of optionals into an optional list, like Haskell's 'sequence'.
    func sequenceMap<T>(_ transform: (Element) throws -> T? ) rethrows -> [T]? {
        var result = [T]()

        for element in self {
            guard let transformed = try transform(element) else { return nil }
            result.append(transformed)
        }

        return result
    }

    func withoutDuplicates<T>(by mapper: (Element) throws -> T) rethrows -> [Element] where T: Hashable {
        var result = [Element]()
        var keys = Set<T>()

        for element in self {
            let key = try mapper(element)
            if !keys.contains(key) {
                keys.insert(key)
                result.append(element)
            }
        }

        return result
    }

    // Groups a sequence, preserving the order of the elements
    func grouped<K>(by mapper: (Element) throws -> K) rethrows -> [(K, [Element])] where K: Hashable {
        try Dictionary(grouping: enumerated(), by: { try mapper($0.1) })
            .map { ($0.0, $0.1.sorted(by: ascendingComparator { $0.0 })) }
            .sorted(by: ascendingComparator { ($0.1)[0].0 })
            .map { ($0.0, $0.1.map(\.1)) }
    }
}

public extension Dictionary where Key: StringProtocol, Value: StringProtocol {
    var urlQueryEncoded: String {
        map { "\($0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? String($0))=\($1.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? String($1))" }
            .joined(separator: "&")
    }
}

public extension Collection {
    var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }

    subscript(safely index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// TODO: Implement this as a generic extension over collections containing optionals
// once Swift supports this.
public func allNonNil<T>(_ array: [T?]) -> [T]? where T: Equatable {
    array.contains(nil) ? nil : array.map { $0! }
}

public extension Array {
    func truncate(_ length: Int, appending appended: Element? = nil) -> [Element] {
        if count > length {
            return appended.map { prefix(length - 1) + [$0] } ?? Array(prefix(length))
        } else {
            return self
        }
    }

    func truncate(_ length: Int, _ appender: ([Element]) -> Element) -> [Element] {
        if count > length {
            return prefix(length - 1) + [appender(Array(dropFirst(length - 1)))]
        } else {
            return self
        }
    }

    func chunks(ofLength chunkLength: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: chunkLength).map { Array(self[$0..<Swift.min($0 + chunkLength, count)]) }
    }

    func repeated(count: Int) -> [Element] {
        assert(count >= 0)
        var result = [Element]()
        for _ in 0..<count {
            result += self
        }
        return result
    }

    /// The longest prefix satisfying the predicate and the rest of the list
    func span(_ inPrefix: (Element) throws -> Bool) rethrows -> (ArraySlice<Element>, ArraySlice<Element>) {
        let pre = try prefix(while: inPrefix)
        let rest = self[pre.endIndex...]
        return (pre, rest)
    }
}

public extension Array where Element: StringProtocol {
    /// Creates a natural language 'enumeration' of the items, e.g.
    ///
    /// ["apples", "bananas", "pears"] -> "apples, bananas and pears"
    func englishEnumerated() -> String {
        switch count {
            case 0: return ""
            case 1: return String(first!)
            default: return "\(prefix(count - 1).joined(separator: ", ")) and \(last!)"
        }
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
