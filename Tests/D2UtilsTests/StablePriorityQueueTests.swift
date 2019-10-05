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
        pq.insert(Item(label: "e", id: 100))
        pq.insert(Item(label: "c", id: 10))
        
        XCTAssertEqual(pq.popMax()?.label, "e")
        XCTAssertEqual(pq.popMax()?.label, "a")
        XCTAssertEqual(pq.popMax()?.label, "b")
        XCTAssertEqual(pq.popMax()?.label, "c")
        XCTAssertEqual(pq.popMax()?.label, "d")
    }
}
