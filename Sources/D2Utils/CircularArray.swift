public struct CircularArray<T>: Sequence {
	private(set) var values = [T]()
	let capacity: Int
	private var insertPos = 0
	
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
		insertPos = (insertPos + 1) % count
	}
	
	public func makeIterator() -> Iterator {
		return Iterator(values: values, capacity: capacity, insertPos: insertPos)
	}
	
	public struct Iterator: IteratorProtocol {
		private var values: [T]
		private let capacity: Int
		private var insertPos: Int
		private var index = 0
		
		public init(values: [T], capacity: Int, insertPos: Int) {
			self.values = values
			self.capacity = capacity
			self.insertPos = insertPos
		}
		
		public mutating func next() -> T? {
			guard index != insertPos else { return nil }
			let element = values[index]
			index = (index + 1) % values.count
			return element
		}
	}
}
