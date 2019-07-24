import XCTest
@testable import D2Utils

final class AvlTreeTests: XCTestCase {
	static var allTests = [
		("testAvlTree", testAvlTree)
	]
	
	func testAvlTree() throws {
		let root = AvlTree(value: 1)
		root.insert(-3)
		XCTAssertEqual(root, Tree.node(.leaf(-3), 1, .empty).avl)
		
		root.insert(0) // Tree has to double-rotate to rebalance itself
		XCTAssertEqual(root, Tree.node(.leaf(-3), 0, .leaf(1)).avl)
		
		root.insert(-5) // Tree still balanced
		XCTAssertEqual(root, Tree.node(.node(.leaf(-5), -3, .empty), 0, .leaf(1)).avl)
		
		root.insert(-6) // Single rotation necessary
		XCTAssertEqual(root, Tree.node(
			.node(.leaf(-6), -5, .leaf(-3)),
			0,
			.leaf(1)
		).avl)
	}
	
	private indirect enum Tree {
		case empty
		case node(Tree, Int, Tree)
		
		static func leaf(_ value: Int) -> Tree {
			return .node(.empty, value, .empty)
		}
		
		/** Returns an AVL tree representing this node. */
		var avl: AvlTree<Int>? {
			switch self {
				case .empty:
					return nil
				case let .node(left, value, right):
					return AvlTree(
						value: value,
						left: left.avl,
						right: right.avl
					)
			}
		}
	}
}
