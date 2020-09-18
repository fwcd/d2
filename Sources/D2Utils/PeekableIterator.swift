public struct PeekableIterator<I>: IteratorProtocol where I: IteratorProtocol {
    private var inner: I
    private var peeked: I.Element? = nil

    public init(_ inner: I) {
        self.inner = inner
    }

    public mutating func next() -> I.Element? {
        if let p = peeked {
            peeked = nil
            return p
        } else {
            return inner.next()
        }
    }

    public mutating func peek() -> I.Element? {
        if peeked == nil {
            peeked = inner.next()
        }
        return peeked
    }
}
