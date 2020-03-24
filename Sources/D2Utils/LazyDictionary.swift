public struct LazyDictionary<K, V>: ExpressibleByDictionaryLiteral, Sequence where K: Hashable {
    private var values: [K: ValueHolder] = [:]
    
    public var count: Int { values.count }
    public var isEmpty: Bool { values.isEmpty }
    
    public init(dictionaryLiteral elements: (K, V)...) {
        for (key, value) in elements {
            values[key] = .computed(value)
        }
    }

    private enum Lazy {
        case lazy(() -> V)
        case computed(V)
    }
    
    public class ValueHolder {
        private var lazyValue: Lazy
        
        private init(from lazyValue: Lazy) {
            self.lazyValue = lazyValue
        }
        
        public static func lazy(_ f: @escaping () -> V) -> ValueHolder { .init(from: .lazy(f)) }
        
        public static func computed(_ v: V) -> ValueHolder { .init(from: .computed(v)) }

        public var value: V {
            switch lazyValue {
                case let .computed(v):
                    return v
                case let .lazy(f):
                    let v = f()
                    lazyValue = .computed(v)
                    return v
            }
        }
    }
    
    public subscript(_ key: K) -> V? {
        get { values[key]?.value }
        set { values[key] = newValue.map { .computed($0) } }
    }
    
    public subscript(lazy key: K) -> ValueHolder? {
        get { values[key] }
        set { values[key] = newValue }
    }
    
    public func makeIterator() -> some IteratorProtocol {
        return values.lazy.map { ($0, $1.value) }.makeIterator()
    }
}
