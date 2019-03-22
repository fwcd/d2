struct UnivISPerson: UnivISObjectNode {
	let nodeType = "Person"
	let key: String
	var atitle: String? = nil
	var title: String? = nil
	var firstname: String? = nil
	var lastname: String? = nil
	var id: UInt? = nil
	var lehr: Bool? = nil
	var locations = [UnivISLocation]()
	var officehours = [UnivISOfficeHour]()
	var orgname: String? = nil
	var orgunits = [String]()
	var visible: Bool? = nil
	var shortDescription: String {
		return "\(title.map { "\($0) " } ?? "")\(firstname ?? "") \(lastname ?? "")"
	}
	
	init(key: String) {
		self.key = key
	}
}
