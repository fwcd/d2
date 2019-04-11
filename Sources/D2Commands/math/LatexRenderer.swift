import Foundation

struct LatexRenderer {
	private let templateURL: URL
	
	init(templateURL: URL) {
		self.templateURL = templateURL
	}
	
	init(templateFilePath: String = "Resources/latex/LatexTemplate.tex") {
		self.init(templateURL: URL(fileURLWithPath: templateFilePath))
	}
	
	private func readTemplate() throws -> String {
		let fileManager = FileManager.default
		
		guard fileManager.fileExists(atPath: templateURL.path) else { throw LatexError.templateFileNotFound(templateURL) }
		guard let data = fileManager.contents(atPath: templateURL.path) else { throw LatexError.noTemplateFileData(templateURL) }
		guard let contents = String(data: data, encoding: .utf8) else { throw LatexError.invalidTemplateFileEncoding(templateURL) }
		
		return contents
	}
}
