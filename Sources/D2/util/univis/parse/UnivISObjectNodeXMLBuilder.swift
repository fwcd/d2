protocol UnivISObjectNodeXMLBuilder: UnivISObjectNodeBuilder {
	func enter(selfWithName elementName: String, attributes: [String : String])
	
	func enter(childWithName elementName: String, attributes: [String : String])
	
	func exit(childWithName elementName: String)
	
	func exit(selfWithName elementName: String)
}
