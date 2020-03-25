import Logging

fileprivate let log = Logger(label: "D2Utils.AvlTree")

/**
 * A balanced binary search tree.
 */
public class AvlTree<Element: Comparable>: Equatable, CustomStringConvertible, SearchTree {
	private var value: Element?
	private var left: AvlTree<Element>? = nil
	private var right: AvlTree<Element>? = nil
	private var balance: Int8 = 0
	private var height: Int
	public var description: String {
		return "[\(left?.description ?? "_") \(value.map { "\($0)" } ?? "_") \(right?.description ?? "_")]"
	}
	
	public convenience init(value: Element? = nil) {
		self.init(value: value, left: nil, right: nil)
	}
	
	// Internal constructor, the left- and
	// right-tree arguments are used solely
	// for testing.
	init(
		value: Element?,
		left: AvlTree<Element>?,
		right: AvlTree<Element>?
	) {
		self.value = value
		self.left = left
		self.right = right
		
		height = (value == nil) ? 0 : 1
	}
	
	@discardableResult
	public func contains(_ element: Element) -> Bool {
		guard let value = self.value else { return false }
		if value == element {
			return true
		} else if element < value {
			return left?.contains(element) ?? false
		} else { // element > value
			return right?.contains(element) ?? false
		}
	}
	
	/**
	 * Inserts a node into the AVL tree,
	 * rebalancing if necessary. The return
	 * value indicates whether the node has
	 * been rebalanced.
	 */
	@discardableResult
	public func insert(_ element: Element) -> Bool {
		guard let value = self.value else {
			self.value = element
			return false
		}
		var rebalanced = false
		
		if element < value {
			rebalanced = insert(element, into: &left)
		} else { // element > value
			rebalanced = insert(element, into: &right)
		}
		
		if !rebalanced {
			updateBalanceAndHeight()
			rebalanced = rebalance()
		}
		
		return rebalanced
	}
	
	private func insert(_ element: Element, into child: inout AvlTree<Element>?) -> Bool {
		if let child = child {
			return child.insert(element)
		} else {
			child = AvlTree(value: element)
			return false
		}
	}
	
	/**
	 * Removes a node from the AVL tree,
	 * rebalancing if necessary. The return
	 * value indicates whether the node has
	 * been rebalanced.
	 */
	@discardableResult
	public func remove(_ element: Element) -> Bool {
		guard let value = self.value else { return false }
		var rebalanced = false
		
		if value == element {
			self.value = nil
		} else if element < value {
			rebalanced = remove(element, from: &left)
		} else if element > value {
			rebalanced = remove(element, from: &right)
		}
		
		if !rebalanced {
			updateBalanceAndHeight()
			rebalanced = rebalance()
		}
		
		return rebalanced
	}
	
	private func remove(_ element: Element, from child: inout AvlTree<Element>?) -> Bool {
		if let child = child {
			return child.remove(element)
		} else {
			child = AvlTree(value: element)
			return false
		}
	}
	
	private func rebalance() -> Bool {
		if balance > 1 {
			// Left-heavy
			if left!.balance > 0 {
				rotateRight()
			} else {
				log.debug("Left-balance: \(left!.balance) of \(self)")
				doubleRotateLeftRight()
			}
			return true
		} else if balance < -1 {
			// Right-heavy
			if right!.balance < 0 {
				rotateLeft()
			} else {
				doubleRotateRightLeft()
			}
			return true
		}
		return false
	}
	
	/**
	 * Performs a simple rotation lowering this node
	 * and lifting up the right child into the current
	 * instance.
	 */
	private func rotateLeft() {
		let oldLifted = right!
		let newLowered = AvlTree(value: value)
		newLowered.left = left
		newLowered.right = oldLifted.left
		
		left = newLowered
		right = oldLifted.right
		value = oldLifted.value
	}
	
	/**
	 * Performs a simple rotation lowering this node
	 * and lifting up the left child into the current
	 * instance.
	 */
	private func rotateRight() {
		let oldLifted = left!
		let newLowered = AvlTree(value: value)
		newLowered.left = oldLifted.right
		newLowered.right = right
		
		left = oldLifted.left
		right = newLowered
		value = oldLifted.value
	}
	
	/**
	 * Performs a double rotation lifting
	 * the left-right grandchild up.
	 */
	private func doubleRotateLeftRight() {
		left!.rotateLeft()
		rotateRight()
	}
	
	/**
	 * Performs a double rotation lifting
	 * the right-left grandchild up.
	 */
	private func doubleRotateRightLeft() {
		right!.rotateRight()
		rotateLeft()
	}
	
	private func updateBalanceAndHeight() {
		let leftHeight = left?.height ?? 0
		let rightHeight = right?.height ?? 0
		balance = Int8(leftHeight - rightHeight)
		height = max(leftHeight, rightHeight) + 1
	}
	
	public static func ==(lhs: AvlTree<Element>, rhs: AvlTree<Element>) -> Bool {
		return (lhs.value == rhs.value)
			&& (lhs.left == rhs.left)
			&& (lhs.right == rhs.right)
	}
}
