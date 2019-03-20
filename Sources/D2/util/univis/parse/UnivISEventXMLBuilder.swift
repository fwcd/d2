struct UnivISEventXMLBuilder: UnivISObjectNodeXMLBuilder {
	private var event: UnivISEvent!
	
	func enter(selfWithName elementName: String, attributes: [String : String]) throws {
		guard let key = attributes["key"] else { throw UnivISError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
		event = UnivISEvent(key: key)
	}
	
	func enter(childWithName elementName: String, attributes: [String : String]) throws {
		// TODO
	}
	
	func exit(childWithName elementName: String) throws {
		// TODO
	}
	
	func exit(selfWithName elementName: String) throws {
		// TODO
	}
	
	func build() -> UnivISObjectNode {
		return event
	}
}
