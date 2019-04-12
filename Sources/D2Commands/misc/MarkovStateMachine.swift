struct MarkovStateMachine<T: Hashable>: Sequence, IteratorProtocol {
	private let matrix: MarkovTransitionMatrix<T>
	private let maxLength: Int
	private(set) var state: [T]
	private var circular
	private(set) var index: Int
	
	init(matrix: MarkovTransitionMatrix<T>, startValue: T, maxLength: Int = Int.max) {
		self.matrix = matrix
		self.maxLength = maxLength
		state = [startValue]
		index = 0
	}
	
	mutating func next() -> T? {
		guard index < maxLength else { return nil }
		let prediction = matrix.predict(state)
		
		push(prediction)
		index += 1
		
		return prediction
	}
	
	private mutating func push(_ stateElement: T) {
		
	}
}
