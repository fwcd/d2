public typealias StableBinaryHeap<E: Comparable> = StablePriorityQueue<BinaryHeap<StableElement<E>>, E>

public struct StableElement<E>: Comparable, CustomStringConvertible where E: Comparable {
    public let inner: E
    public let insertion: Int
    public var description: String { return "(\(inner))<\(insertion)>" }
    
    public static func <(lhs: StableElement<E>, rhs: StableElement<E>) -> Bool {
        if lhs.inner == rhs.inner {
            return lhs.insertion < rhs.insertion
        } else {
            return lhs.inner < rhs.inner
        }
    }
    
    public static func ==(lhs: StableElement<E>, rhs: StableElement<E>) -> Bool {
        return lhs.inner == rhs.inner && lhs.insertion == rhs.insertion
    }
}

/**
 * A wrapper around a priority queue that
 * ensures a FIFO order for elements of the
 * same priority.
 */
public struct StablePriorityQueue<Q, E>: PriorityQueue where Q: PriorityQueue, E: Comparable, Q.Element == StableElement<E> {
    public typealias Element = E
    
    // Only accessible (internally) for testing purposes
    private(set) var inner: Q = Q.init()
    public var count: Int { return inner.count }
    private var counter: Int = 0
    
    public init() {}
    
    public mutating func insert(_ element: E) {
        inner.insert(StableElement(inner: element, insertion: counter))
        counter -= 1
    }
    
    public mutating func popMax() -> E? {
        return inner.popMax()?.inner
    }
}
