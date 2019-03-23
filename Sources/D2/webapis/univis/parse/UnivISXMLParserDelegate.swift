import Foundation

class UnivISXMLParserDelegate: XMLParserDelegate {
	let then: (Result<UnivISOutputNode>) -> Void
	let registeredBuilderFactories: [String: () -> UnivISObjectNodeXMLBuilder] = [
		"Event": { UnivISEventXMLBuilder() },
		"Room": { UnivISRoomXMLBuilder() },
		"Person": { UnivISPersonXMLBuilder() },
		"Lecture": { UnivISLectureXMLBuilder() }
	]
	
	var nodes = [UnivISObjectNode]()
	var nodeBuilder: UnivISObjectNodeXMLBuilder? = nil
	var currentName: String? = nil
	var currentCharacters = ""
	var hasErrored = false
	
	init(then: @escaping (Result<UnivISOutputNode>) -> Void) {
		self.then = then
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
		// print("Started \(elementName)")
		do {
			// Ignore top-level 'UnivIS' element
			guard elementName != "UnivIS" else { return }
			
			if let builder = nodeBuilder {
				// Enter child node in existing builder
				try builder.enter(childWithName: elementName, attributes: attributeDict)
			} else if let builderFactory = registeredBuilderFactories[elementName] {
				// Enter object node by creating a new builder
				let builder = builderFactory()
				try builder.enter(selfWithName: elementName, attributes: attributeDict)
				
				nodeBuilder = builder
				currentName = elementName
			} // else ignore unrecognized element
		} catch {
			then(.error(error))
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		// print("Got \(string)")
		currentCharacters += string
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		// print("Ended \(elementName)")
		do {
			if elementName == "UnivIS" {
				print("Ending parsing")
				then(.ok(UnivISOutputNode(childs: nodes)))
			} else if let builder = nodeBuilder {
				if elementName == currentName {
					// Exit object node
					try builder.exit(selfWithName: elementName)
					nodes.append(builder.build())
					
					nodeBuilder = nil
					currentName = nil
				} else {
					if !currentCharacters.isEmpty {
						// Pass the accumulated characters
						try builder.characters(currentCharacters)
					}
					
					try builder.exit(childWithName: elementName)
				}
			} // else ignore elements outside of builders
			
			currentCharacters = ""
		} catch {
			then(.error(error))
		}
	}
	
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		if !hasErrored {
			then(.error(parseError))
			hasErrored = true
		}
	}
	
	func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
		if !hasErrored {
			then(.error(validationError))
			hasErrored = true
		}
	}
}
