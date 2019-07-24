/**
 * A balanced binary search tree.
 */
public class AvlTree<Element: Comparable>: Equatable {
	private var value: Element?
	private var left: AvlTree<Element>? = nil
	private var right: AvlTree<Element>? = nil
	private var balance: UInt8 = 0
	private var height: Int = 0
	
	public init(value: Element? = nil) {
		self.value = value
	}
	
	public func contains(_ element: Element) -> Bool {
		guard let value = self.value else { return false }
		if value == element {
			return true
		} else if element < value {
			return left?.contains(element) ?? false
		} else if element > value {
			return right?.contains(element) ?? false
		}
	}
	
	/**
	 * Inserts a node into the AVL tree,
	 * rebalancing if necessary. The return
	 * value indicates whether the node has
	 * been rebalanced.
	 */
	public func insert(_ element: Element) -> Bool {
		if value == nil {
			value = element
		} else if element < value! {
			return insert(element, into: &left)
		} else if element > value! {
			return insert(element, into: &right)
		}
		return false
	}
	
	private func insert(_ element: Element, into child: inout AvlTree<Element>?) -> Bool {
		var rebalanced = false
		
		if let child = child {
			rebalanced = child.insert(element)
		} else {
			child = AvlTree(value: element)
		}
		
		if !rebalanced {
			updateBalanceAndHeight()
			rebalanced = rebalance()
		}
		
		return rebalanced
	}
	
	/**
	 * Removes a node from the AVL tree,
	 * rebalancing if necessary. The return
	 * value indicates whether the node has
	 * been rebalanced.
	 */
	public func remove(_ element: Element) -> Bool {
		if value == element {
			value = nil
		} else if element < value! {
			return remove(element, from: &left)
		} else if element > value! {
			return remove(element, from: &right)
		}
		return false
	}
	
	private func remove(_ element: Element, from child: inout AvlTree<Element>?) -> Bool {
		var rebalanced = false
		
		if let child = child {
			rebalanced = child.remove(element)
		} else {
			child = AvlTree(value: element)
		}
		
		if !rebalanced {
			updateBalanceAndHeight()
			rebalanced = rebalance()
		}
		
		return rebalanced
	}
	
	private func rebalance() -> Bool {
		if balance > 1 {
			// Left-heavy
			if left!.balance > 1 {
				rotateRight()
			} else {
				doubleRotateLeftRight()
			}
			return true
		} else if balance < 1 {
			// Right-heavy
			if right!.balance < 1 {
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
		let leftHeight = left!.height
		let rightHeight = right!.height
		balance = UInt8(leftHeight - rightHeight)
		height = max(leftHeight, rightHeight) + 1
	}
	
	public static func ==(lhs: AvlTree<Element>, rhs: AvlTree<Element>) -> Bool {
		return (lhs.value == rhs.value)
			&& (lhs.left == rhs.left)
			&& (lhs.right == rhs.right)
	}
}
