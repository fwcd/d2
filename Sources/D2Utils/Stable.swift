public struct StableElement<E>: Comparable where E: Comparable {
    public let inner: E
    public let insertion: Int
    
    public static func <(lhs: StableElement<E>, rhs: StableElement<E>) -> Bool {
        if lhs.inner == rhs.inner {
            return lhs.insertion > rhs.insertion
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
public struct Stable<Q, E>: PriorityQueue where Q: PriorityQueue, E: Comparable, Q.Element == StableElement<E> {
    public typealias Element = E

    private var inner: Q = Q.init()
    private var counter: Int = 0
    
    public init() {}
    
    public mutating func enqueue(_ element: E) {
        inner.enqueue(StableElement(inner: element, insertion: counter))
        counter += 1
    }
    
    public mutating func dequeue() -> E? {
        return inner.dequeue()?.inner
    }
}
