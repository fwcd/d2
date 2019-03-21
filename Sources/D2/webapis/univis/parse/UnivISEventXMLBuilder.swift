class UnivISEventXMLBuilder: UnivISObjectNodeXMLBuilder {
	private var event: UnivISEvent! = nil
	
	private var parsingRef = false
	private var currentTerm: UnivISTerm? = nil
	private var nameStack = [String]()
	
	// TODO: Parse orgunits
	
	func enter(selfWithName elementName: String, attributes: [String : String]) throws {
		guard let key = attributes["key"] else { throw UnivISError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
		event = UnivISEvent(key: key)
	}
	
	func enter(childWithName elementName: String, attributes: [String : String]) throws {
		let previousName = nameStack.last
		nameStack.append(elementName)
		
		if parsingRef {
			if elementName == "UnivISRef" {
				guard let key = attributes["key"] else { throw UnivISError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
				switch previousName {
					case "room": currentTerm!.room = UnivISRef(key: key)
					case "contact": event.contact = UnivISRef(key: key)
					case "dbref": event.dbref = UnivISRef(key: key)
					default: break
				}
			}
		} else if currentTerm != nil {
			switch elementName {
				case "room": parsingRef = true
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
		let str = characters.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if let name = nameStack.last {
			if var term = currentTerm {
				switch name {
					case "endate": term.enddate = str
					case "endtime": term.endtime = str
					case "startdate": term.startdate = str
					case "starttime": term.starttime = str
					default: break
				}
			} else {
				switch name {
					case "enddate": event.enddate = str
					case "id": event.id = UInt(str)
					case "orgname": event.orgname = str
					case "startdate": event.startdate = str
					case "title": event.title = str
					default: break
				}
			}
		}
	}
	
	func exit(childWithName elementName: String) throws {
		if parsingRef {
			if elementName == "room" {
				parsingRef = false
			}
		} else if elementName == "term", let term = currentTerm {
			currentTerm = nil
			event.terms.append(term)
		}
		
		_ = nameStack.removeLast()
		print("Now with \(nameStack)")
	}
	
	func exit(selfWithName elementName: String) throws {}
	
	func build() -> UnivISObjectNode {
		return event
	}
}
