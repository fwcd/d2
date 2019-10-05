import XCTest
@testable import D2Utils

final class BinaryHeapTests: XCTestCase {
    static var allTests = [
        ("testBinaryHeap", testBinaryHeap)
    ]
    
    func testBinaryHeap() throws {
        var heap = BinaryHeap<Int>()
        heap.insert(7)
        XCTAssert(heap.isValidHeap())
        heap.insert(4)
        XCTAssert(heap.isValidHeap())
        heap.insert(5)
        XCTAssert(heap.isValidHeap())
        heap.insert(-20)
        XCTAssert(heap.isValidHeap())
        heap.insert(98)
        XCTAssert(heap.isValidHeap())
        heap.insert(0)
        XCTAssert(heap.isValidHeap())
        heap.insert(1)
        XCTAssert(heap.isValidHeap())
        
        XCTAssertEqual(heap.popMax(), 98)
        XCTAssert(heap.isValidHeap())
        XCTAssertEqual(heap.popMax(), 7)
        XCTAssert(heap.isValidHeap())
        XCTAssertEqual(heap.popMax(), 5)
        XCTAssert(heap.isValidHeap())
        XCTAssertEqual(heap.popMax(), 4)
        XCTAssert(heap.isValidHeap())
        XCTAssertEqual(heap.popMax(), 1)
        XCTAssert(heap.isValidHeap())
        XCTAssertEqual(heap.popMax(), 0)
        XCTAssert(heap.isValidHeap())
        XCTAssertEqual(heap.popMax(), -20)
        XCTAssert(heap.isValidHeap())
        XCTAssert(heap.isEmpty)
    }
}
