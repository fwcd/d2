import Foundation
import Logging
import Utils
import CairoGraphics

fileprivate let log = Logger(label: "D2Commands.LatexRenderer")
fileprivate let latexPrefix = "latex"

class LatexRenderer {
    private let node = NodePackage(name: "latex-renderer")

    func renderImage(from formula: String, color: String = "white", scale: Double = 2) async throws -> CairoImage {
        try await CairoImage(pngData: renderPNG(from: formula, color: color, scale: scale))
    }

    private func renderPNG(from formula: String, color: String, scale: Double) async throws -> Data {
        log.debug("Invoking latex-renderer")
        return try await node.start(withArgs: [formula, "--color", color, "--scale", String(scale)])
    }
}
