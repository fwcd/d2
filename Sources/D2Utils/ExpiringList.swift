import Foundation

/**
 * A linked list of expiring elements.
 */
public class ExpiringList<T>: Sequence {
    public typealias Element = T

    private var head: Node? = nil
    private var tail: Node? = nil
    private var currentCount: Int = 0
    public var count: Int {
        removeExpired()
        return currentCount
    }

    class Node {
        let element: T
        let expiry: Date
        var next: Node? = nil
        
        init(element: T, expiry: Date) {
            self.element = element
            self.expiry = expiry
        }
    }
    
    public struct Iterator: IteratorProtocol {
        private var current: Node?
        
        init(from head: Node?) {
            current = head
        }
        
        public mutating func next() -> T? {
            let value = current?.element
            current = current?.next
            return value
        }
    }

    public func append(_ element: T, expiry: Date) {
        removeExpired()

        let node = Node(element: element, expiry: expiry)
        tail?.next = node
        tail = node
        if head == nil {
            head = node
        }
        
        currentCount += 1
    }
    
    private func removeExpired() {
        while (head?.expiry.timeIntervalSinceNow ?? 1) < 0 {
            head = head?.next
            currentCount -= 1
        }
    }
    
    public func makeIterator() -> Iterator {
        removeExpired()
        return Iterator(from: head)
    }
}
