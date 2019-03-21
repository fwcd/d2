class UnivISRoomXMLBuilder: UnivISObjectNodeXMLBuilder {
	private var room: UnivISRoom! = nil
	
	private var parsingRef = false
	private var currentTerm: UnivISTerm? = nil
	private var nameStack = [String]()
	
	// TODO: Parse orgunits
	
	func enter(selfWithName elementName: String, attributes: [String : String]) throws {
		guard let key = attributes["key"] else { throw UnivISError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
		room = UnivISRoom(key: key)
	}
	
	func enter(childWithName elementName: String, attributes: [String : String]) throws {
		var previousName = nameStack.last
		nameStack.append(elementName)
		
		if parsingRef {
			if elementName == "UnivISRef" {
				guard let key = attributes["key"] else { throw UnivISError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
				switch previousName {
					case "contact": currentTerm!.contacts.append(UnivISRef(key: key))
					default: break
				}
			}
		} else {
			switch elementName {
				case "contact": parsingRef = true
				default: break
			}
		}
	}
	
	func characters(_ characters: String) throws {
		let str = characters.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if let name = nameStack.last {
			switch name {
				case "address": room.address = str
				case "chtab": room.chtab = parseUnivISBool(str)
				case "description": room.description = str
				case "id": room.id = UInt(str)
				case "inet": room.inet = parseUnivISBool(str)
				case "beam": room.beam = parseUnivISBool(str)
				case "dark": room.dark = parseUnivISBool(str)
				case "lose": room.lose = parseUnivISBool(str)
				case "ohead": room.ohead = parseUnivISBool(str)
				case "wlan": room.wlan = parseUnivISBool(str)
				case "tafel": room.tafel = parseUnivISBool(str)
				case "laptopton": room.laptopton = parseUnivISBool(str)
				case "fest": room.fest = parseUnivISBool(str)
				case "tel": room.tel = str
				case "name": room.name = str
				case "orgname": room.orgname = str
				case "rolli": room.rolli = parseUnivISBool(str)
				case "short": room.short = str
				case "size": room.size = Int(str)
				case "wb": room.wb = parseUnivISBool(str)
				default: break
			}
		}
	}
	
	func exit(childWithName elementName: String) throws {
		if parsingRef {
			if elementName == "contact" {
				parsingRef = false
			}
		}
		
		_ = nameStack.removeLast()
	}
	
	func exit(selfWithName elementName: String) throws {}
	
	func build() -> UnivISObjectNode {
		return room
	}
}
