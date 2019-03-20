struct UnivISLecture: UnivISObjectNode {
	let key: String
	let classification: UnivISRef?
	let dozs: [UnivISRef]
	let id: Int?
	let name: String?
	let number: Int?
	let ordernr: Int?
	let orgname: String?
	let orgunits: [String]
	let sws: Int?
	let terms: [UnivISTerm]
	let type: String?
	let parentLv: UnivISRef?
	let short: String?
	let startdate: String?
	let turnout: Int?
	let ects: Bool?
	let ectsCred: Int?
	let literature: String?
	let organizational: String?
	let evaluation: Bool?
	let summary: String?
}
