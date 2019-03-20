import Foundation

class UnivISXMLParserDelegate: XMLParserDelegate {
	let then: (Result<UnivISOutputNode>) -> Void
	
	init(then: @escaping (Result<UnivISOutputNode>) -> Void) {
		self.then = then
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {
		// TODO
	}
	
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		then(.error(parseError))
	}
	
	func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
		then(.error(validationError))
	}
}
