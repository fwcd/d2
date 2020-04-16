import D2Utils

struct MarkovStateMachine<P: MarkovPredictor>: Sequence, IteratorProtocol where P.Element: Hashable {
	private let predictor: P
	private let maxLength: Int
	private(set) var state: CircularArray<P.Element>
	private(set) var index: Int
	
	init(predictor: P, initialState: [P.Element], maxLength: Int = Int.max) {
		self.predictor = predictor
		self.maxLength = maxLength
		state = CircularArray(capacity: predictor.markovOrder)
		for value in initialState {
			state.push(value)
		}
		index = 0
	}
	
	mutating func next() -> P.Element? {
		guard index < maxLength else { return nil }
		guard let prediction = predictor.predict(Array(state)) else { return nil }
		
		state.push(prediction)
		index += 1
		
		return prediction
	}
}
