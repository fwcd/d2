struct MarkovTransitionMatrix<T: Hashable> {
	private var values = [[T]: T]()
	
	init() {}
	
	init(fromElements elements: [T], order: Int) {
		for i in 0..<(elements.count - order) {
			values[Array(elements[i..<(i + order)])] = elements[i + order]
		}
	}
	
	subscript(previousState: [T]) -> T? {
		get { return values[previousState] }
		set(next) { values[previousState] = next }
	}
}
