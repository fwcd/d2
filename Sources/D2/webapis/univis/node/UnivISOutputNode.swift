struct UnivISOutputNode {
	let childs: [UnivISObjectNode]
	
	func resolve(ref: UnivISRef) -> UnivISObjectNode? {
		return childs.first { $0.key == ref.key }
	}
}
