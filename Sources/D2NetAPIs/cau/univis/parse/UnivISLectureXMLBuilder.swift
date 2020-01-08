class UnivISLectureXMLBuilder: UnivISObjectNodeXMLBuilder {
	private var lecture: UnivISLecture! = nil
	
	private var parsingRef = false
	private var currentTerm: UnivISTerm? = nil
	private var nameStack = [String]()
	
	// TODO: Parse orgunits and dozs
	
	func enter(selfWithName elementName: String, attributes: [String: String]) throws {
		guard let key = attributes["key"] else { throw NetApiError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
		lecture = UnivISLecture(key: key)
	}
	
	func enter(childWithName elementName: String, attributes: [String: String]) throws {
		let previousName = nameStack.last
		nameStack.append(elementName)
		
		if parsingRef {
			if elementName == "UnivISRef" {
				guard let key = attributes["key"] else { throw NetApiError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
				switch previousName {
					case "room": currentTerm!.room = UnivISRef(key: key)
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
			if currentTerm != nil {
				switch name {
					case "endate": currentTerm!.enddate = str
					case "endtime": currentTerm!.endtime = str
					case "startdate": currentTerm!.startdate = str
					case "starttime": currentTerm!.starttime = str
					case "repeat": currentTerm!.repeatPattern = str
					default: break
				}
			} else {
				switch name {
					case "ects": lecture.ects = parse(univISBool: str)
					case "ects_cred": lecture.ectsCred = Int(str)
					case "enddate": lecture.enddate = str
					case "evaluation": lecture.evaluation = parse(univISBool: str)
					case "id": lecture.id = Int(str)
					case "literature": lecture.literature = str
					case "name": lecture.name = str
					case "number": lecture.number = Int(str)
					case "ordernr": lecture.ordernr = Int(str)
					case "orgname": lecture.orgname = str
					case "short": lecture.short = str
					case "startdate": lecture.startdate = str
					case "summary": lecture.summary = str
					case "sws": lecture.sws = Int(str)
					case "turnout": lecture.turnout = Int(str)
					case "type": lecture.type = str
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
			lecture.terms.append(term)
		}
		
		_ = nameStack.removeLast()
	}
	
	func exit(selfWithName elementName: String) throws {}
	
	func build() -> UnivISObjectNode {
		return lecture
	}
}
