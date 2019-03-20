import Foundation

class UnivISXMLParserDelegate: XMLParserDelegate {
	let then: (Result<UnivISOutputNode>) -> Void
	let registeredBuilderFactories: [String : () -> UnivISObjectNodeXMLBuilder] = [
		
	]
	
	var nodes = [UnivISObjectNode]()
	var nodeBuilder: UnivISObjectNodeXMLBuilder? = nil
	var currentName: String? = nil
	
	init(then: @escaping (Result<UnivISOutputNode>) -> Void) {
		self.then = then
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {
		then(.ok())
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		// Ignore top-level 'UnivIS' element
		guard elementName != "UnivIS" else { return }
		
		if let builder = nodeBuilder {
			// Enter child node in existing builder
			builder.enter(childWithName: elementName, attributes: attributes)
		} else if let builderFactory = registeredBuilderFactories[elementName] {
			// Enter object node by creating a new builder
			let builder = builderFactory()
			builder.enter(selfWithName: elementName, attributes: attributes)
			
			nodeBuilder = builder
			currentName = elementName
		} // else ignore unrecognized element
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		// Ignore top-level 'UnivIS' element
		guard elementName != "UnivIS" else { return }
		
		if let builder = nodeBuilder {
			if elementName == currentName {
				// Exit object node
				builder.exit(selfWithName: elementName)
				nodes.append(builder.build())
				
				nodeBuilder = nil
				currentName = nil
			} else {
				builder.exit(childWithName: elementName)
			}
		} // else ignore elements outside of builders
	}
	
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		then(.error(parseError))
	}
	
	func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
		then(.error(validationError))
	}
}
