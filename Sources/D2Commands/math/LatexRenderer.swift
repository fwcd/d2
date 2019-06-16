import Foundation
import D2Utils
import D2Graphics

class LatexRenderer {
	private let templateURL: URL
	private let textPlaceholder: String
	private let colorPlaceholder: String
	private let packagesPlaceholder: String
	private let tempDir = TemporaryDirectory() // Will be automatically deleted when deinitialized
	private var lastFilename: String? = nil
	
	init(templateURL: URL, textPlaceholder: String, colorPlaceholder: String, packagesPlaceholder: String) throws {
		self.templateURL = templateURL
		self.textPlaceholder = textPlaceholder
		self.colorPlaceholder = colorPlaceholder
		self.packagesPlaceholder = packagesPlaceholder
		
		try tempDir.create()
	}
	
	convenience init(
		templateFilePath: String = "Resources/latex/LatexTemplate.tex",
		textPlaceholder: String = "TextPlaceholder",
		colorPlaceholder: String = "TextColorPlaceholder",
		packagesPlaceholder: String = "PackagesPlaceholder"
	) throws {
		try self.init(templateURL: URL(fileURLWithPath: templateFilePath), textPlaceholder: textPlaceholder, colorPlaceholder: colorPlaceholder, packagesPlaceholder: packagesPlaceholder)
	}
	
	deinit {
		cleanUp()
	}
	
	func renderPNG(from formula: String, color: String, packages: [String], onError: @escaping (Error) -> Void, then: @escaping (Image) -> Void) throws {
		try renderPDF(from: formula, color: color, packages: packages, onError: onError) { name, _ in
			let pngFile = self.tempDir.childFile(named: "\(name)-1.png")
			
			do {
				try self.shellInvoke("pdftocairo", in: self.tempDir.url, args: ["\(name).pdf", "-transp", "-png", "\(name)"]) { _ in
					do {
						then(try Image(fromPngFile: pngFile.url))
					} catch {
						onError(error)
					}
				}
			} catch {
				onError(error)
			}
		}
	}
	
	private func renderPDF(from formula: String, color: String, packages: [String], onError: @escaping (Error) -> Void, then: @escaping (_ name: String, _ pdfFile: TemporaryFile) -> Void) throws {
		let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
		let filename = "latex-\(timestamp)"
		let texName = "\(filename).tex"
		let texFile = tempDir.childFile(named: texName)
		let logFile = self.tempDir.childFile(named: "\(filename).log")
		
		cleanUp()
		lastFilename = filename
		
		print("Writing TeX file")
		try texFile.write(utf8: try template(appliedTo: formula, color: color, packages: packages))
		
		print("Invoking pdflatex")
		try shellInvoke("pdflatex", in: tempDir.url, args: ["-halt-on-error", texName]) { _ in
			let pdfFile = self.tempDir.childFile(named: "\(filename).pdf")
			var resultingError: Error? = nil
			
			if pdfFile.exists {
				then(filename, pdfFile)
			} else {
				resultingError = LatexError.pdfError(log: logFile.readUTF8() ?? "Could not read TeX log")
			}
			
			if let error = resultingError {
				onError(error)
			}
		}
	}
	
	func cleanUp() {
		if let lastName = lastFilename {
			do {
				try self.cleanUpTexFiles(name: lastName)
			} catch {
				print("Error while cleaning up tex files: \(error)")
			}
		}
	}
	
	private func cleanUpTexFiles(name: String) throws {
		let fileManager = FileManager.default
		for file in try fileManager.contentsOfDirectory(at: self.tempDir.url, includingPropertiesForKeys: nil) {
			if file.lastPathComponent.starts(with: name) {
				try fileManager.removeItem(at: file)
			}
		}
	}
	
	private func shellInvoke(_ executable: String, in dirURL: URL, args: [String], then: @escaping (Process) -> Void) throws {
		let shell = Shell()
		
		do {
			try shell.run(executable, in: dirURL, args: args, then: then)
		} catch {
			throw LatexError.processError(executable: executable, cause: error)
		}
	}
	
	private func readTemplate() throws -> String {
		let fileManager = FileManager.default
		
		guard fileManager.fileExists(atPath: templateURL.path) else { throw LatexError.templateFileNotFound(templateURL) }
		guard let data = fileManager.contents(atPath: templateURL.path) else { throw LatexError.noTemplateFileData(templateURL) }
		guard let contents = String(data: data, encoding: .utf8) else { throw LatexError.invalidTemplateFileEncoding(templateURL) }
		
		return contents
	}
	
	private func template(appliedTo formula: String, color: String, packages: [String]) throws -> String {
		return try readTemplate()
			.replacingOccurrences(of: textPlaceholder, with: formula)
			.replacingOccurrences(of: colorPlaceholder, with: color)
			.replacingOccurrences(of: packagesPlaceholder, with: packages.map { "\\usepackage{\($0)}" }.joined(separator: "\n"))
	}
}
