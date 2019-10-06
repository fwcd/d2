public struct BinaryHeap<E>: PriorityQueue where E: Comparable {
    public typealias Element = E
    
    // Only accessible (internally) for testing purposes
    private(set) var elements: [E] = []
    public var count: Int { return elements.count }
    
    public init() {}
    
    public mutating func insert(_ element: E) {
        elements.append(element)
        if elements.count > 1 {
            heapifyUp(at: elements.count - 1)
        }
    }
    
    public mutating func popMax() -> E? {
        if elements.count <= 1 {
            return elements.popLast()
        } else {
            let removed = elements[0]
            elements.swapAt(0, elements.count - 1)
            elements.removeLast()
            heapifyDown(at: 0)
            return removed
        }
    }
    
    private mutating func heapifyUp(at index: Int) {
        let par = parent(of: index)
        if par >= 0 {
            if elements[par] < elements[index] {
                elements.swapAt(par, index)
                heapifyUp(at: par)
            }
        }
    }
    
    private mutating func heapifyDown(at index: Int) {
        let left = leftChild(of: index)
        let right = rightChild(of: index)
        var child: Int? = nil
        
        if left < elements.count {
            if elements[left] > elements[index] {
                child = left
            }
        }
        
        if right < elements.count {
            if elements[right] > elements[child ?? index] {
                child = right
            }
        }

        if let c = child {
            elements.swapAt(c, index)
            heapifyDown(at: c)
        }
    }
    
    /** Internal function to check the validity of this heap. */
    func isValidHeap(at index: Int = 0) -> Bool {
        let left = leftChild(of: index)
        let right = rightChild(of: index)

        if left < elements.count {
            if elements[left] > elements[index] { return false }
            isValidHeap(at: left)
        }
        
        if right < elements.count {
            if elements[right] > elements[index] { return false }
            isValidHeap(at: right)
        }
        
        return true
    }
    
    private func leftChild(of index: Int) -> Int { return 2 * index + 1 }
    
    private func rightChild(of index: Int) -> Int { return 2 * index + 2 }
    
    private func parent(of index: Int) -> Int { return (index - 1) / 2 }
    
    private func isLeaf(_ index: Int) -> Bool { return leftChild(of: index) >= elements.count || rightChild(of: index) >= elements.count }
}
