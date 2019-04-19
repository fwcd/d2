import Foundation

class WolframAlphaParserDelegate: NSObject, XMLParserDelegate {
	let then: (Result<WolframAlphaOutput, Error>) -> Void
	
	private var result = WolframAlphaOutput()
	private var currentCharacters = ""
	private var hasErrored = false
	
	init(then: @escaping (Result<WolframAlphaOutput, Error>) -> Void) {
		self.then = then
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
		// TODO
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		currentCharacters += string
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "queryresult" {
			print("Ending parsing")
			then(.success(result))
		} else {
			if !currentCharacters.isEmpty {
				// TODO
			}
		}
		
		currentCharacters = ""
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
	
	private func parseBool(from str: String) -> Bool? {
		switch str.lowercased() {
			case "true": return true
			case "false": return false
			default: return nil
		}
	}
}
