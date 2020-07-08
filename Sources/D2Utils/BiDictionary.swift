/// A dictionary supporting bidirectional lookup.
public struct BiDictionary<K, V>: ExpressibleByDictionaryLiteral, Sequence, Hashable, Equatable, CustomStringConvertible where K: Hashable, V: Hashable {
    public private(set) var keysToValues: [K: V]
    public private(set) var valuesToKeys: [V: K]

    public var keys: Dictionary<K, V>.Keys { keysToValues.keys }
    public var values: Dictionary<V, K>.Keys { valuesToKeys.keys }
    public var count: Int { keysToValues.count }
    public var isEmpty: Bool { count == 0 }

    public var description: String { "\(keysToValues)" }

    public init() {
        keysToValues = [:]
        valuesToKeys = [:]
    }

    public init(dictionaryLiteral elements: (K, V)...) {
        self.init()

        for (key, value) in elements {
            self[key] = value
        }
    }

    public subscript(_ key: K) -> V? {
        get { keysToValues[key] }
        set(value) {
            if let previousValue = keysToValues[key] {
                valuesToKeys[previousValue] = nil
            }

            keysToValues[key] = value

            if let v = value {
                valuesToKeys[v] = key
            }
        }
    }

    public subscript(value value: V) -> K? {
        get { valuesToKeys[value] }
        set(key) {
            if let previousKey = valuesToKeys[value] {
                keysToValues[previousKey] = nil
            }

            valuesToKeys[value] = key

            if let k = key {
                keysToValues[k] = value
            }
        }
    }

    public func makeIterator() -> Dictionary<K, V>.Iterator {
        keysToValues.makeIterator()
    }
}
