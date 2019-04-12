/** A stateless transition table. */
struct MarkovTransitionMatrix<T: Hashable> {
	private var values = [[T]: [T]]()
	
	init() {}
	
	init(fromElements elements: [T], order: Int) {
		for i in 0..<(elements.count - order) {
			let key = Array(elements[i..<(i + order)])
			let next = elements[i + order]
			
			if values.keys.contains(key) {
				values[key]!.append(next)
			} else {
				values[key] = [next]
			}
		}
	}
	
	subscript(_ previousState: [T]) -> [T] {
		get { return values[previousState] ?? [] }
		set(next) { values[previousState] = next }
	}
	
	private func suffixDistance(between a: [T], and b: [T]) -> Int {
		let minCount = min(a.count, b.count)
		return (0..<minCount).filter { a[(a.count - 1) - $0] != b[(b.count - 1) - $0] }.count
	}
	
	func predict(_ state: [T]) -> T? {
		let next = values[state] ?? values.sorted { suffixDistance(between: $0, and: state) }.first
		return next?.randomElement()
	}
}
