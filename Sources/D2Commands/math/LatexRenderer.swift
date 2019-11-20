import Foundation
import D2Utils
import D2Graphics

fileprivate let LATEX_PREFIX = "latex"

class LatexRenderer {
	private let node = NodePackage(name: "latex-renderer")
	private let tempDir = TemporaryDirectory() // Will be automatically deleted when deinitialized
	
	init() throws {
		try tempDir.create()
	}
	
	deinit {
		cleanUp()
	}
	
	func renderImage(from formula: String, color: String = "white", scale: Int = 6, onError: @escaping (Error) -> Void, then: @escaping (Image) -> Void) throws {
		let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
		let outputFile = tempDir.childFile(named: "\(LATEX_PREFIX)-\(timestamp).png")

		try renderPNG(from: formula, to: outputFile, color: color, scale: scale, onError: onError) {
			do {
				then(try Image(fromPngFile: outputFile.url))
			} catch {
				onError(error)
			}
		}
	}
	
	private func renderPNG(from formula: String, to outputFile: TemporaryFile, color: String, scale: Int, onError: @escaping (Error) -> Void, then: @escaping () -> Void) throws {
		cleanUp()
		print("Invoking latex-renderer")
		try node.start(withArgs: [formula, color, outputFile.url.path, String(scale)]) { _ in
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
}
