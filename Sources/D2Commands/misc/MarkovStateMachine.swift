import D2Utils

struct MarkovStateMachine<P: MarkovPredictor>: Sequence, IteratorProtocol where P.Element: Hashable {
	private let predictor: P
	private let maxLength: Int
	private(set) var state: CircularArray<P.Element>
	private(set) var index: Int
	
	private var initialIterator: Array<P.Element>.Iterator
	
	init(predictor: P, initialState: [P.Element], maxLength: Int = Int.max) {
		self.predictor = predictor
		self.maxLength = maxLength
		initialIterator = initialState.makeIterator()
		state = CircularArray(capacity: predictor.markovOrder)

		for value in initialState {
			state.push(value)
		}

		index = 0
	}
	
	mutating func next() -> P.Element? {
		if let value = initialIterator.next() { return value }
		guard index < maxLength else { return nil }
		guard let prediction = predictor.predict(Array(state)) else { return nil }
		
		state.push(prediction)
		index += 1
		
		return prediction
	}
}
