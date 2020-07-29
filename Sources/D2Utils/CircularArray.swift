public struct CircularArray<T>: Sequence {
    private var values = [T]()
    public let capacity: Int
    private(set) var insertPos = 0

    public var isEmpty: Bool { return values.isEmpty }
    public var count: Int { return values.count }

    public init(capacity: Int) {
        self.capacity = capacity
    }

    public subscript(_ index: Int) -> T {
        get { return values[index] }
        set(newValue) { values[index] = newValue }
    }

    public mutating func push(_ value: T) {
        if count < capacity {
            values.append(value)
        } else {
            values[insertPos] = value
        }
        insertPos = (insertPos + 1) % capacity
    }

    public func makeIterator() -> Iterator {
        return Iterator(values: values, capacity: capacity, insertPos: insertPos)
    }

    public struct Iterator: IteratorProtocol {
        private let values: [T]
        private let capacity: Int
        private let insertPos: Int
        private let destinationPos: Int
        private let checkFirstIteration: Bool
        private var isFirstIteration: Bool = true
        private var index: Int

        public init(values: [T], capacity: Int, insertPos: Int) {
            self.values = values
            self.capacity = capacity
            self.insertPos = insertPos

            if values.count >= capacity {
                // Circular array is filled, wrap around while iterating
                index = insertPos
                destinationPos = insertPos
                checkFirstIteration = false
            } else {
                // Circular array is not filled, iterate normally
                index = 0
                destinationPos = values.count
                checkFirstIteration = true
            }
        }

        public mutating func next() -> T? {
            guard (isFirstIteration && !checkFirstIteration) || (index != destinationPos) else { return nil }

            let element = values[index]
            index = (index + 1) % capacity
            isFirstIteration = false

            return element
        }
    }
}
