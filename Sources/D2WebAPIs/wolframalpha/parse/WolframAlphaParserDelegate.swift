import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

class WolframAlphaParserDelegate: NSObject, XMLParserDelegate {
	let then: (Result<WolframAlphaOutput, Error>) -> Void
	
	// Current parser state
	private var result = WolframAlphaOutput()
	private var pod = WolframAlphaPod()
	private var subpod = WolframAlphaSubpod()
	private var state = WolframAlphaState()
	private var image = WolframAlphaImage()
	private var link = WolframAlphaLink()
	private var info = WolframAlphaInfo()
	private var parsingInfo = false
	
	private var currentCharacters = ""
	private var hasErrored = false
	
	init(then: @escaping (Result<WolframAlphaOutput, Error>) -> Void) {
		self.then = then
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
		// print("Entering \(elementName): \(attributeDict)")
		switch elementName {
			case "queryresult":
				result = WolframAlphaOutput()
				result.success = attributeDict["success"].flatMap { parseBool(from: $0) }
				result.error = attributeDict["error"].flatMap { parseBool(from: $0) }
				result.numpods = attributeDict["numpods"].flatMap { Int($0) }
				result.timing = attributeDict["timing"].flatMap { Double($0) }
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
			case "link":
				link = WolframAlphaLink()
				link.url = attributeDict["url"]
				link.text = attributeDict["text"]
				link.title = attributeDict["title"]
				parsingInfo = true
			case "info":
				info = WolframAlphaInfo()
				info.text = attributeDict["text"]
			default: break
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		currentCharacters += string
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		// print("Exiting \(elementName)")
		if elementName == "queryresult" {
			print("Ending parsing")
			then(.success(result))
		} else {
			switch elementName {
				case "pod": result.pods.append(pod)
				case "subpod": pod.subpods.append(subpod)
				case "state": pod.states.append(state)
				case "plaintext": subpod.plaintext = currentCharacters
				case "info":
					pod.infos.append(info)
					parsingInfo = false
				case "link":
					if parsingInfo {
						info.links.append(link)
					}
				case "img":
					if parsingInfo {
						info.img = image
					} else {
						subpod.img = image
					}
				default: break
			}
		}
		
		currentCharacters = ""
	}
	
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		print(parseError)
		if !hasErrored {
			then(.failure(parseError))
			hasErrored = true
		}
	}
	
	func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
		print(validationError)
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
