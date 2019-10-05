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
    
    init()
    
    /** Removes the element with the highest priority. */
    mutating func dequeue() -> Element?
    
    /** Inserts an element. */
    mutating func enqueue(_ element: Element)
}
