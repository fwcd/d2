public struct PeekableIterator<I>: IteratorProtocol where I: IteratorProtocol {
    private var inner: I
    private var peeked: I.Element? = nil

    public private(set) var current: I.Element? = nil

    public init(_ inner: I) {
        self.inner = inner
    }

    public mutating func next() -> I.Element? {
        if let p = peeked {
            peeked = nil
            current = p
        } else {
            current = inner.next()
        }
        return current
    }

    public mutating func peek() -> I.Element? {
        if peeked == nil {
            peeked = inner.next()
        }
        return peeked
    }
}
