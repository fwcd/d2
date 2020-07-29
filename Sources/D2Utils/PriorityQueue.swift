/**
 * A data structure that allows efficient
 * insertion and dequeueing of prioritized items.
 *
 * This protocol does _not_ make any guarantees
 * regarding the order of elements with the same
 * priority. Use the `Stable` wrapper to ensure
 * a FIFO order, if this property is desired.
 */
public protocol PriorityQueue {
    associatedtype Element: Comparable
    var count: Int { get }

    init()

    /** Removes the element with the highest priority. */
    mutating func popMax() -> Element?

    /** Inserts an element. */
    mutating func insert(_ element: Element)
}

public extension PriorityQueue {
    var isEmpty: Bool { return count == 0 }

    init<S>(_ elements: S) where S: Sequence, S.Element == Element {
        self.init()
        for element in elements {
            insert(element)
        }
    }
}
