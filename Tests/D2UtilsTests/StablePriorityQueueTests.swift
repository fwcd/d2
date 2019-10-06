import XCTest
@testable import D2Utils

final class StablePriorityQueueTests: XCTestCase {
    static var allTests = [
        ("testStableBinaryHeap", testStableBinaryHeap)
    ]
    
    private struct Item: Comparable {
        let label: String
        let id: Int
        
        static func <(lhs: Item, rhs: Item) -> Bool {
            return lhs.id < rhs.id
        }
        
        static func ==(lhs: Item, rhs: Item) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    func testStableBinaryHeap() throws {
        var pq = StableBinaryHeap<Item>()
        pq.insert(Item(label: "a", id: 10))
        pq.insert(Item(label: "d", id: 2))
        pq.insert(Item(label: "b", id: 10))
        assert(heap: pq, containsInOrder: ["a", "d", "b"])
        pq.insert(Item(label: "e", id: 100))
        assert(heap: pq, containsInOrder: ["e", "a", "b", "d"])
        pq.insert(Item(label: "c", id: 10))
        assert(heap: pq, containsInOrder: ["e", "a", "b", "d", "c"])
        
        XCTAssertEqual(pq.popMax()?.label, "e")
        assert(heap: pq, containsInOrder: ["a", "c", "b", "d"])
        XCTAssertEqual(pq.popMax()?.label, "a")
        assert(heap: pq, containsInOrder: ["b", "c", "d"])
        XCTAssertEqual(pq.popMax()?.label, "b")
        assert(heap: pq, containsInOrder: ["c", "d"])
        XCTAssertEqual(pq.popMax()?.label, "c")
        assert(heap: pq, containsInOrder: ["d"])
        XCTAssertEqual(pq.popMax()?.label, "d")
    }
    
    private func assert(heap: StableBinaryHeap<Item>, containsInOrder labels: [String]) {
        XCTAssertEqual(heap.inner.elements.map { $0.inner.label }, labels)
    }
}
