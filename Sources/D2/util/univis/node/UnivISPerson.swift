struct UnivISPerson: UnivISObjectNode {
	let key: String
	let atitle: String?
	let title: String?
	let firstname: String?
	let lastname: String?
	let id: UInt?
	let lehr: Bool?
	let locations: [UnivISLocation]
	let officehours: [UnivISOfficeHour]
	let orgname: String?
	let orgunits: [String]
	let visible: Bool?
}
