struct UnivISEventXMLBuilder: UnivISObjectNodeXMLBuilder {
	private var event: UnivISEvent! = nil
	
	private var currentTerm: UnivISTerm? = nil
	private var nameStack = [String]()
	private var parsingRoomRef = false
	
	func enter(selfWithName elementName: String, attributes: [String : String]) throws {
		guard let key = attributes["key"] else { throw UnivISError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
		event = UnivISEvent(key: key)
	}
	
	func enter(childWithName elementName: String, attributes: [String : String]) throws {
		nameStack.append(elementName)
		
		if parsingRoomRef {
			parsingRoomRef = (elementName == "UnivISRef")
		} else if let term = currentTerm {
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
	
	func characters(_ characters: String) throws {
		if parsingRoomRef {
			term.room = characters
		} else if let name = nameStack.last {
			if let term = currentTerm {
				switch name {
					case "endate": term.enddate = characters
					case "endtime": term.endtime = characters
					case "startdate": term.startdate = characters
					case "starttime": term.starttime = starttime
					default: break
				}
			}
		}
	}
	
	func exit(childWithName elementName: String) throws {
		if let term = currentTerm {
			currentTerm = nil
			event.terms.append(term)
		}
		
		nameStack.popLast()
	}
	
	func exit(selfWithName elementName: String) throws {}
	
	func build() -> UnivISObjectNode {
		return event
	}
}
