extension Collection {
	public subscript(safely index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
