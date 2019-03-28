extension String {
	var nilIfEmpty: String? {
		return isEmpty ? nil : self
	}
	
	func split(by length: Int) -> [String] {
		var start = startIndex
		var output = [String]()
		
		while start < endIndex {
			let end = index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
			output.append(String(self[start..<end]))
			start = end
		}
		
		return output
	}
}
