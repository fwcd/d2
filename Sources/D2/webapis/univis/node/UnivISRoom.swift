struct UnivISRoom: UnivISObjectNode {
	let key: String
	var address: String? = nil
	var chtab: Bool? = nil
	var contacts = [UnivISRef]()
	var description: String? = nil
	var id: UInt? = nil
	var inet: Bool? = nil
	var beam: Bool? = nil
	var dark: Bool? = nil
	var lose: Bool? = nil
	var ohead: Bool? = nil
	var wlan: Bool? = nil
	var tafel: Bool? = nil
	var laptopton: Bool? = nil
	var fest: Bool? = nil
	var tel: String? = nil
	var name: String? = nil
	var orgname: String? = nil
	var orgunits = [String]()
	var rolli: Bool? = nil
	var short: String? = nil
	var size: Int? = nil
	var wb: Bool? = nil
	
	init(key: String) {
		self.key = key
	}
}
