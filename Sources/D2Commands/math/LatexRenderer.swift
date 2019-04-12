import Foundation
import D2Utils
import D2Graphics

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
	
	public func renderPNG(from formula: String, then: @escaping (Image) throws -> Void) throws {
		try renderPDF(from: formula) { name, _ in
			let pngName = "\(name).png"
			let pdfName = "\(name).pdf"
			let pngFile = self.tempDir.childFile(named: pngName)
			
			try self.shellInvoke("pdftocairo", in: self.tempDir.url, args: [pdfName, pngName]) {
				try then(try Image(fromPngURL: pngFile.url))
			}
		}
	}
	
	private func renderPDF(from formula: String, then: @escaping (_ name: String, _ pdfFile: TemporaryFile) throws -> Void) throws {
		let timestamp = Date().timeIntervalSince1970
		let filename = "latex-\(timestamp)"
		let texFile = tempDir.childFile(named: "\(filename).tex")
		
		texFile.deleteAutomatically = false
		try texFile.write(utf8: try template(appliedTo: formula))
		
		try shellInvoke("pdflatex", in: tempDir.url, args: [filename]) {
			let pdfFile = self.tempDir.childFile(named: "\(filename).pdf")
			var latexError: LatexError? = nil
			
			if pdfFile.exists {
				try then(filename, pdfFile)
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
	
	private func shellInvoke(_ executable: String, in dirURL: URL, args: [String], then: @escaping () throws -> Void) throws {
		let process = Process()
		process.executableURL = URL(fileURLWithPath: executable)
		process.currentDirectoryURL = dirURL
		process.arguments = args
		process.terminationHandler = { _ in
			do {
				try then()
			} catch {
				print("A latex error occurred while running \(executable)'s termination callback: \(error)")
			}
		}
		try process.run()
		print("Finished '\(executable)' process")
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
