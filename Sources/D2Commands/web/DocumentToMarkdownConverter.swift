import SwiftSoup

struct DocumentToMarkdownConverter {
	private let defaultPrefix = ""
	private let defaultPostfix = ""
	
	func convert(_ element: Element) throws -> String {
		let mdPrefix: String
		let mdPostfix: String
		
		switch element.tagName() {
			case "a":
				if let href = try? element.attr("href") {
					mdPrefix = "["
					mdPostfix = "](\(href))"
				} else {
					mdPrefix = defaultPrefix
					mdPostfix = defaultPostfix
				}
			case "b", "strong", "em":
				mdPrefix = "**"
				mdPostfix = "**"
			case "i":
				mdPrefix = "*"
				mdPostfix = "*"
			case "u":
				mdPrefix = "__"
				mdPostfix = "__"
			case "p":
				mdPrefix = "\n\n"
				mdPostfix = "\n\n"
			case "h1", "h2", "h3", "h4", "h5", "h6":
				mdPrefix = "\n**"
				mdPostfix = "**\n"
			default:
				mdPrefix = defaultPrefix
				mdPostfix = defaultPostfix
		}
		
		let content = try element.getChildNodes().map {
			if let childElement = $0 as? Element {
				return try convert(childElement)
			} else if let childText = $0 as? TextNode {
				return childText.getWholeText()
			} else {
				return ""
			}
		}.joined()
		return "\(mdPrefix)\(content)\(mdPostfix)"
	}
}
