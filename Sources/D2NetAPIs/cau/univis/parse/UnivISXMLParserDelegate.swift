import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import Logging
import D2Utils

fileprivate let log = Logger(label: "D2NetAPIs.UnivISXMLParserDelegate")

class UnivISXMLParserDelegate: NSObject, XMLParserDelegate {
	let then: (Result<UnivISOutputNode, Error>) -> Void
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
	
	init(then: @escaping (Result<UnivISOutputNode, Error>) -> Void) {
		self.then = then
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
		log.trace("Started \(elementName)")
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
			then(.failure(error))
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		log.trace("Got \(string)")
		currentCharacters += string
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		log.trace("Ended \(elementName)")
		do {
			if elementName == "UnivIS" {
				log.trace("Ending parsing")
				then(.success(UnivISOutputNode(childs: nodes)))
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
			then(.failure(error))
		}
	}
	
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		if !hasErrored {
			then(.failure(parseError))
			hasErrored = true
		}
	}
	
	func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
		if !hasErrored {
			then(.failure(validationError))
			hasErrored = true
		}
	}
}
