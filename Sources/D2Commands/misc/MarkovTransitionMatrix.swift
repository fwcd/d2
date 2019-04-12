/** A stateless transition table. */
struct MarkovTransitionMatrix<T: Hashable> {
	private var values = [[T]: [T]]()
	let order: Int
	
	init() {
		order = 1
	}
	
	init<C: RandomAccessCollection>(fromElements elements: C, order: Int) where C.Element == T, C.Index == Int {
		self.order = order
		
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
		return (0..<min(a.count, b.count))
			.filter { (i: Int) -> Bool in a[(a.count - 1) - i] != b[(b.count - 1) - i] }
			.count
	}
	
	func predict(_ state: [T]) -> T? {
		let next = values[state] ?? values
			.sorted { suffixDistance(between: $0.key, and: state) < suffixDistance(between: $1.key, and: state) }
			.first?
			.value
		return next?.randomElement()
	}
}
