protocol UnivISObjectNodeXMLBuilder: UnivISObjectNodeBuilder {
	mutating func enter(selfWithName elementName: String, attributes: [String : String]) throws
	
	mutating func enter(childWithName elementName: String, attributes: [String : String]) throws
	
	mutating func characters(_ characters: String) throws
	
	mutating func exit(childWithName elementName: String) throws
	
	mutating func exit(selfWithName elementName: String) throws
}
