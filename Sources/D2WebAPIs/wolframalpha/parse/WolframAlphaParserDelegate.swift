import Foundation

class WolframAlphaParserDelegate: NSObject, XMLParserDelegate {
	let then: (Result<WolframAlphaOutput, Error>) -> Void
	
	// Current parser state
	private var result = WolframAlphaOutput()
	private var pod = WolframAlphaPod()
	private var subpod = WolframAlphaSubpod()
	private var state = WolframAlphaState()
	private var image = WolframAlphaImage()
	
	private var currentCharacters = ""
	private var hasErrored = false
	
	init(then: @escaping (Result<WolframAlphaOutput, Error>) -> Void) {
		self.then = then
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
		switch elementName {
			case "pod":
				pod = WolframAlphaPod()
				pod.title = attributeDict["title"]
				pod.scanner = attributeDict["scanner"]
				pod.id = attributeDict["id"]
				pod.position = attributeDict["position"].flatMap { Int($0) }
				pod.error = attributeDict["error"].flatMap { parseBool(from: $0) }
				pod.numsubpods = attributeDict["numsubpods"].flatMap { Int($0) }
			case "subpod":
				subpod = WolframAlphaSubpod()
				subpod.title = attributeDict["title"]
			case "state":
				state = WolframAlphaState()
				state.name = attributeDict["name"]
				state.input = attributeDict["input"]
			case "img":
				image = WolframAlphaImage()
				image.src = attributeDict["src"]
				image.alt = attributeDict["alt"]
				image.title = attributeDict["title"]
				image.width = attributeDict["width"].flatMap { Int($0) }
				image.height = attributeDict["height"].flatMap { Int($0) }
			default: break
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		currentCharacters += string
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "queryresult" {
			print("Ending parsing")
			then(.success(result))
		} else {
			switch elementName {
				case "pod": result.pods.append(pod)
				case "subpod": pod.subpods.append(subpod)
				case "state": pod.states.append(state)
				case "plaintext": subpod.plaintext = currentCharacters
				case "img": subpod.img = image
				default: break
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
