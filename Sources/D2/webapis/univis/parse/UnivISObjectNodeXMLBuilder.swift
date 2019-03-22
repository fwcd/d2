protocol UnivISObjectNodeXMLBuilder: UnivISObjectNodeBuilder {
	func enter(selfWithName elementName: String, attributes: [String: String]) throws
	
	func enter(childWithName elementName: String, attributes: [String: String]) throws
	
	func characters(_ characters: String) throws
	
	func exit(childWithName elementName: String) throws
	
	func exit(selfWithName elementName: String) throws
}
