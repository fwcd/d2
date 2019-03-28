struct UnivISTitle: UnivISObjectNode, Hashable {
	let nodeType = "Title"
	let key: String
	var title: String? = nil
	var titleEn: String? = nil
	var ordernr: Int? = nil
	var parentTitle: UnivISRef? = nil
	var text: String? = nil
	var shortDescription: String {
		return "\(title ?? "?"): \(text ?? "?")"
	}
	
	init(key: String) {
		self.key = key
	}
}
