struct UnivISEvent: UnivISObjectNode {
	let key: String
	let contact: UnivISRef?
	let dbref: UnivISRef?
	let enddate: String?
	let id: UInt?
	let orgname: String?
	let orgunits: [String]
	let startdate: String?
	let terms: [UnivISTerm]
	let title: String?
}
