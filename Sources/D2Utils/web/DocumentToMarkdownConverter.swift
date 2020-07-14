import Foundation
import SwiftSoup

public struct DocumentToMarkdownConverter {
	private let defaultPrefix: String
	private let defaultPostfix: String

	public init(
		defaultPrefix: String = "",
		defaultPostfix: String = ""
	) {
		self.defaultPrefix = defaultPrefix
		self.defaultPostfix = defaultPostfix
	}

	/** Parses and converts a full HTML document to Markdown. */
	public func convert(htmlDocument: String, baseURL: URL? = nil) throws -> String {
		try convert(SwiftSoup.parse(htmlDocument), baseURL: baseURL)
	}

	/** Parses and converts an HTML snippet to Markdown. */
	public func convert(htmlFragment: String, baseURL: URL? = nil) throws -> String {
		try convert(SwiftSoup.parseBodyFragment(htmlFragment), baseURL: baseURL)
	}
	
	/** Converts an HTML element to Markdown. */
	public func convert(_ element: Element, baseURL: URL? = nil) throws -> String {
		let mdPrefix: String
		let mdPostfix: String
		var trimContent: Bool = false
		
		switch element.tagName() {
			case "a":
				if let href = try? element.attr("href") {
					mdPrefix = "["
					mdPostfix = "](\(URL(string: href, relativeTo: baseURL)?.absoluteString ?? href))"
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
				trimContent = true
			case "h1", "h2", "h3", "h4", "h5", "h6":
				mdPrefix = "\n**"
				mdPostfix = "**\n"
			case "img":
				mdPrefix = (try? element.attr("alt")) ?? defaultPrefix
				mdPostfix = defaultPostfix
			default:
				mdPrefix = defaultPrefix
				mdPostfix = defaultPostfix
		}
		
		var content = try element.getChildNodes().map {
			if let childElement = $0 as? Element {
				return try convert(childElement, baseURL: baseURL)
			} else if let childText = ($0 as? TextNode)?.getWholeText() {
				var trimmed = childText.trimmingCharacters(in: .whitespacesAndNewlines)
				if childText.hasPrefix(" ") { trimmed = " \(trimmed)" }
				if childText.hasSuffix(" ") { trimmed += " " }
				return trimmed
			} else {
				return ""
			}
		}.joined()
		
		if trimContent {
			content = content.trimmingCharacters(in: .whitespacesAndNewlines)
		}
		
		if content.isEmpty {
			return ""
		} else {
			return "\(mdPrefix)\(content)\(mdPostfix)"
		}
	}
}
