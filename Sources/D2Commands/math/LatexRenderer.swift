import Foundation

struct LatexRenderer {
	private let templateURL: URL
	
	init(templateURL: URL) {
		self.templateURL = templateURL
	}
	
	init(templateFilePath: String = "Resources/latex/LatexTemplate.tex") {
		self.init(URL(fileURLWithPath: templateFilePath))
	}
}
