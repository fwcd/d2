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
		do {
			// Ignore top-level 'UnivIS' element
			guard elementName != "UnivIS" else { return }
			
			if let builder = nodeBuilder {
				// Enter child node in existing builder
				try builder.enter(childWithName: elementName, attributes: attributes)
			} else if let builderFactory = registeredBuilderFactories[elementName] {
				// Enter object node by creating a new builder
				let builder = builderFactory()
				try builder.enter(selfWithName: elementName, attributes: attributes)
				
				nodeBuilder = builder
				currentName = elementName
			} // else ignore unrecognized element
		} catch {
			then(.error(error))
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		do {
			// Ignore top-level 'UnivIS' element
			guard elementName != "UnivIS" else { return }
			
			if let builder = nodeBuilder {
				if elementName == currentName {
					// Exit object node
					try builder.exit(selfWithName: elementName)
					nodes.append(builder.build())
					
					nodeBuilder = nil
					currentName = nil
				} else {
					try builder.exit(childWithName: elementName)
				}
			} // else ignore elements outside of builders
		} catch {
			then(.error(error))
		}
	}
	
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		then(.error(parseError))
	}
	
	func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
		then(.error(validationError))
	}
}
