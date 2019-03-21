class UnivISRoomXMLBuilder: UnivISObjectNodeXMLBuilder {
	private var room: UnivISRoom! = nil
	
	private var parsingRef = false
	private var currentTerm: UnivISTerm? = nil
	private var nameStack = [String]()
	
	func enter(selfWithName elementName: String, attributes: [String : String]) throws {
		guard let key = attributes["key"] else { throw UnivISError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
		room = UnivISRoom(key: key)
	}
	
	func enter(childWithName elementName: String, attributes: [String : String]) throws {
		nameStack.append(elementName)
		
		if parsingRef {
			if elementName == "UnivISRef" {
				guard let key = attributes["key"] else { throw UnivISError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
				currentTerm!.room = UnivISRef(key: key)
			}
		} else {
			// TODO
		}
	}
	
	func characters(_ characters: String) throws {
		let str = characters.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if let name = nameStack.last {
			if parsingRef {
				// TODO
			} else {
				// TODO
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
