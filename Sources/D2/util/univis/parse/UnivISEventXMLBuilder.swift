struct UnivISEventXMLBuilder: UnivISObjectNodeXMLBuilder {
	private var event: UnivISEvent! = nil
	
	private var currentTerm: UnivISTerm? = nil
	private var nameStack = [String]()
	private var parsingRoomRef = false
	
	mutating func enter(selfWithName elementName: String, attributes: [String : String]) throws {
		guard let key = attributes["key"] else { throw UnivISError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
		event = UnivISEvent(key: key)
	}
	
	mutating func enter(childWithName elementName: String, attributes: [String : String]) throws {
		nameStack.append(elementName)
		
		if parsingRoomRef {
			parsingRoomRef = (elementName == "UnivISRef")
		} else if currentTerm != nil {
			switch elementName {
				case "room": parsingRoomRef = true
				default: break
			}
		} else {
			switch elementName {
				case "term": currentTerm = UnivISTerm()
				default: break
			}
		}
	}
	
	mutating func characters(_ characters: String) throws {
		if parsingRoomRef {
			currentTerm!.room = UnivISRef(key: characters)
		} else if let name = nameStack.last {
			if var term = currentTerm {
				switch name {
					case "endate": term.enddate = characters
					case "endtime": term.endtime = characters
					case "startdate": term.startdate = characters
					case "starttime": term.starttime = characters
					default: break
				}
			}
		}
	}
	
	mutating func exit(childWithName elementName: String) throws {
		if elementName == "term", let term = currentTerm {
			currentTerm = nil
			event.terms.append(term)
		}
		
		_ = nameStack.popLast()
	}
	
	func exit(selfWithName elementName: String) throws {}
	
	func build() -> UnivISObjectNode {
		return event
	}
}
