import Foundation
import Logging
import Utils
import CairoGraphics

fileprivate let log = Logger(label: "D2Commands.LatexRenderer")
fileprivate let latexPrefix = "latex"

class LatexRenderer {
    private let node = NodePackage(name: "latex-renderer")

    func renderImage(from formula: String, color: String = "white", scale: Double = 2) -> Promise<CairoImage, any Error> {
        renderPNG(from: formula, color: color, scale: scale)
            .mapCatching { try CairoImage(pngData: $0) }
    }

    private func renderPNG(from formula: String, color: String, scale: Double) -> Promise<Data, any Error> {
        log.debug("Invoking latex-renderer")
        return node.start(withArgs: [formula, "--color", color, "--scale", String(scale)])
    }
}
