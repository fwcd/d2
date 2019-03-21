struct UnivISLecture: UnivISObjectNode {
	let key: String
	var classification: UnivISRef? = nil
	var dozs = [UnivISRef]()
	var id: Int? = nil
	var name: String? = nil
	var number: Int? = nil
	var ordernr: Int? = nil
	var orgname: String? = nil
	var orgunits = [String]()
	var sws: Int? = nil
	var terms = [UnivISTerm]()
	var type: String? = nil
	var parentLv: UnivISRef?
	var short: String? = nil
	var startdate: String? = nil
	var turnout: Int? = nil
	var ects: Bool? = nil
	var ectsCred: Int? = nil
	var literature: String? = nil
	var organizational: String? = nil
	var evaluation: Bool? = nil
	var summary: String? = nil
	
	init(key: String) {
		self.key = key
	}
}
