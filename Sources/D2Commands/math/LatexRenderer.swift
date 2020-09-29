import Foundation
import Logging
import Utils
import Graphics

fileprivate let log = Logger(label: "D2Commands.LatexRenderer")
fileprivate let latexPrefix = "latex"

class LatexRenderer {
    private let node = NodePackage(name: "latex-renderer")
    private let tempDir = TemporaryDirectory() // Will be automatically deleted when deinitialized

    init() throws {
        try tempDir.create()
    }

    deinit {
        cleanUp()
    }

    func renderImage(from formula: String, color: String = "white", scale: Double = 6) -> Promise<Image, Error> {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
        let outputFile = tempDir.childFile(named: "\(latexPrefix)-\(timestamp).png")

        return renderPNG(from: formula, to: outputFile, color: color, scale: scale)
            .mapCatching { try Image(fromPngFile: outputFile.url) }
    }

    private func renderPNG(from formula: String, to outputFile: TemporaryFile, color: String, scale: Double) -> Promise<Void, Error> {
        cleanUp()
        log.debug("Invoking latex-renderer")
        // TODO: Handle MathJax errors
        return node.start(withArgs: [formula, color, outputFile.url.path, String(scale)]).void()
    }

    func cleanUp() {
        do {
            try self.cleanUpTexFiles()
        } catch {
            log.error("Error while cleaning up tex files: \(error)")
        }
    }

    private func cleanUpTexFiles() throws {
        let fileManager = FileManager.default
        for file in try fileManager.contentsOfDirectory(at: self.tempDir.url, includingPropertiesForKeys: nil) {
            if file.lastPathComponent.starts(with: latexPrefix) {
                try fileManager.removeItem(at: file)
            }
        }
    }
}
