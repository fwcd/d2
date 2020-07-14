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

	public func plainTextOf(htmlFragment: String) throws -> String {
		try SwiftSoup.parseBodyFragment(htmlFragment).text()
	}
	
	/** Converts an HTML element to Markdown. */
	public func convert(_ element: Element, baseURL: URL? = nil, usedPrefixes: Set<String> = [], usedPostfixes: Set<String> = []) throws -> String {
		var mdPrefix: String = defaultPrefix
		var mdPostfix: String = defaultPostfix
		var mdIfEmpty: String = ""
		var trimContent: Bool = false
		
		switch element.tagName() {
			case "a":
				if let href = try? element.attr("href") {
					mdPrefix = "["
					mdPostfix = "](\(URL(string: href, relativeTo: baseURL)?.absoluteString ?? href))"
				}
			case "b", "strong", "em":
				if usedPrefixes.contains("**") {
					mdPrefix = "*"
					mdPostfix = "*"
				} else {
					mdPrefix = "**"
					mdPostfix = "**"
				}
			case "i":
				mdPrefix = "*"
				mdPostfix = "*"
			case "u":
				mdPrefix = "__"
				mdPostfix = "__"
			case "br":
				mdIfEmpty = "\n"
			case "p":
				mdPrefix = "\n\n"
				mdPostfix = "\n\n"
				mdIfEmpty = "\n\n"
				trimContent = true
			case "pre", "tt", "code", "samp":
				mdPrefix = "`"
				mdPostfix = "`"
				trimContent = true
			case "h1", "h2", "h3", "h4", "h5", "h6":
				mdPrefix = "\n**"
				mdPostfix = "**\n"
			case "img":
				mdPrefix = (try? element.attr("alt")) ?? defaultPrefix
				mdPostfix = defaultPostfix
			default:
				break
		}

		if usedPrefixes.contains(mdPrefix) {
			mdPrefix = defaultPrefix
		}
		if usedPostfixes.contains(mdPostfix) {
			mdPostfix = defaultPostfix
		}
		
		var content = try element.getChildNodes().map {
			if let childElement = $0 as? Element {
				return try convert(childElement, baseURL: baseURL, usedPrefixes: usedPrefixes.union([mdPrefix]), usedPostfixes: usedPostfixes.union([mdPostfix]))
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
			return mdIfEmpty
		} else {
			return "\(mdPrefix)\(content)\(mdPostfix)"
		}
	}
}
