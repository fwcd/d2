extension String {
	var nilIfEmpty: String? {
		return isEmpty ? nil : self
	}
}
