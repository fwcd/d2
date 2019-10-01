import Foundation
import D2Utils
import D2Graphics

fileprivate let LATEX_PREFIX = "latex"

class LatexRenderer {
	private let rendererURL: URL
	private let tempDir = TemporaryDirectory() // Will be automatically deleted when deinitialized
	
	init(rendererURL: URL) throws {
		self.rendererURL = rendererURL
		try tempDir.create()
	}
	
	convenience init(
		templateFilePath: String = "Node/latex-renderer"
	) throws {
		try self.init(rendererURL: URL(fileURLWithPath: templateFilePath))
	}
	
	deinit {
		cleanUp()
	}
	
	func renderImage(from formula: String, color: String, onError: @escaping (Error) -> Void, then: @escaping (Image) -> Void) throws {
		let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
		let outputFile = tempDir.childFile(named: "\(LATEX_PREFIX)-\(timestamp).png")

		try renderPNG(from: formula, to: outputFile, color: color, onError: onError) {
			do {
				let img = try Image(fromPngFile: outputFile.url)
				
				for y in 0..<img.height {
					for x in 0..<img.width {
						img[y, x] = img[y, x].with(
							red: 0xFF,
							green: 0xFF,
							blue: 0xFF
						)
					}
				}

				then(img)
			} catch {
				onError(error)
			}
		}
	}
	
	private func renderPNG(from formula: String, to outputFile: TemporaryFile, color: String, onError: @escaping (Error) -> Void, then: @escaping () -> Void) throws {
		cleanUp()
		print("Invoking latex-renderer")
		try shellInvoke("npm", in: rendererURL, args: ["start", formula, outputFile.url.path]) { _ in
			// TODO: Handle MathJax errors
			then()
		}
	}
	
	func cleanUp() {
		do {
			try self.cleanUpTexFiles()
		} catch {
			print("Error while cleaning up tex files: \(error)")
		}
	}
	
	private func cleanUpTexFiles() throws {
		let fileManager = FileManager.default
		for file in try fileManager.contentsOfDirectory(at: self.tempDir.url, includingPropertiesForKeys: nil) {
			if file.lastPathComponent.starts(with: LATEX_PREFIX) {
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
}
