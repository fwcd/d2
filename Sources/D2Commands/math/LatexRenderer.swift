import Foundation
import D2Utils

struct LatexRenderer {
	private let templateURL: URL
	private let textPlaceholder: String
	private let tempDir = TemporaryDirectory() // Will be automatically deleted when deinitialized
	
	init(templateURL: URL, textPlaceholder: String) {
		self.templateURL = templateURL
		self.textPlaceholder = textPlaceholder
	}
	
	init(templateFilePath: String = "Resources/latex/LatexTemplate.tex", textPlaceholder: String = "TextPlaceholder") {
		self.init(templateURL: URL(fileURLWithPath: templateFilePath), textPlaceholder: textPlaceholder)
	}
	
	private func renderPDF(from formula: String, then: @escaping (TemporaryFile) -> Void) throws {
		let timestamp = Date().timeIntervalSince1970
		let filename = "latex-\(timestamp)"
		let texFile = tempDir.childFile(named: "\(filename).tex")
		
		texFile.deleteAutomatically = false
		try texFile.write(utf8: try template(appliedTo: formula))
		
		try invokePDFLatex(at: tempDir.url, with: [filename]) {
			let pdfFile = self.tempDir.childFile(named: "\(filename).pdf")
			var latexError: LatexError? = nil
			
			if pdfFile.exists {
				then(pdfFile)
			} else {
				let logFile = self.tempDir.childFile(named: "\(filename).log")
				latexError = .noPDFGenerated(log: logFile.readUTF8() ?? "Could not read log file")
			}
			
			// Clean up generated files
			let fileManager = FileManager.default
			for file in try fileManager.contentsOfDirectory(at: self.tempDir.url, includingPropertiesForKeys: nil) {
				if file.lastPathComponent.starts(with: filename) {
					try fileManager.removeItem(at: file)
				}
			}
			
			if let error = latexError {
				throw error
			}
		}
	}
	
	private func invokePDFLatex(at url: URL, with args: [String], then: @escaping () throws -> Void) throws {
		let process = Process()
		process.executableURL = URL(fileURLWithPath: "pdflatex")
		process.currentDirectoryURL = url
		process.arguments = args
		process.terminationHandler = { _ in
			do {
				try then()
			} catch {
				print("A latex error occurred while running pdflatex's termination callback: \(error)")
			}
		}
		try process.run()
		print("Finished 'pdflatex' process")
	}
	
	private func readTemplate() throws -> String {
		let fileManager = FileManager.default
		
		guard fileManager.fileExists(atPath: templateURL.path) else { throw LatexError.templateFileNotFound(templateURL) }
		guard let data = fileManager.contents(atPath: templateURL.path) else { throw LatexError.noTemplateFileData(templateURL) }
		guard let contents = String(data: data, encoding: .utf8) else { throw LatexError.invalidTemplateFileEncoding(templateURL) }
		
		return contents
	}
	
	private func template(appliedTo formula: String) throws -> String {
		return try readTemplate().replacingOccurrences(of: textPlaceholder, with: formula)
	}
}
