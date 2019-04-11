import Foundation

struct LatexRenderer {
	private let templateURL: URL
	private let textPlaceholder: String
	
	init(templateURL: URL, textPlaceholder: String) {
		self.templateURL = templateURL
		self.textPlaceholder = textPlaceholder
	}
	
	init(templateFilePath: String = "Resources/latex/LatexTemplate.tex", textPlaceholder: String = "TextPlaceholder") {
		self.init(templateURL: URL(fileURLWithPath: templateFilePath), textPlaceholder: textPlaceholder)
	}
	
	private func readTemplate() throws -> String {
		let fileManager = FileManager.default
		
		guard fileManager.fileExists(atPath: templateURL.path) else { throw LatexError.templateFileNotFound(templateURL) }
		guard let data = fileManager.contents(atPath: templateURL.path) else { throw LatexError.noTemplateFileData(templateURL) }
		guard let contents = String(data: data, encoding: .utf8) else { throw LatexError.invalidTemplateFileEncoding(templateURL) }
		
		return contents
	}
	
	private func applyTemplate(to formula: String) throws -> String {
		return try readTemplate().replacingOccurrences(of: textPlaceholder, with: formula)
	}
}
