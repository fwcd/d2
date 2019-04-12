import D2Utils

struct MarkovStateMachine<T: Hashable>: Sequence, IteratorProtocol {
	private let matrix: MarkovTransitionMatrix<T>
	private let maxLength: Int
	private(set) var state: CircularArray<T>
	private(set) var index: Int
	
	init(matrix: MarkovTransitionMatrix<T>, startValue: T, maxLength: Int = Int.max) {
		self.matrix = matrix
		self.maxLength = maxLength
		state = CircularArray(capacity: matrix.order)
		state.push(startValue)
		index = 0
	}
	
	mutating func next() -> T? {
		guard index < maxLength else { return nil }
		guard let prediction = matrix.predict(Array(state)) else { return nil }
		
		state.push(prediction)
		index += 1
		
		return prediction
	}
}
