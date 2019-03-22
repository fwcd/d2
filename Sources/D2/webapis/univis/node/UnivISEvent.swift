struct UnivISEvent: UnivISObjectNode {
	let nodeType = "Event"
	let key: String
	var contact: UnivISRef? = nil
	var dbref: UnivISRef? = nil
	var enddate: String? = nil
	var id: UInt? = nil
	var orgname: String? = nil
	var orgunits = [String]()
	var startdate: String? = nil
	var terms = [UnivISTerm]()
	var title: String? = nil
	var shortDescription: String {
		return "\(title ?? "?"): \(startdate.map { "\($0) " } ?? "")\(enddate.map { "-> \($0)" } ?? "")"
	}
	
	init(key: String) {
		self.key = key
	}
}
