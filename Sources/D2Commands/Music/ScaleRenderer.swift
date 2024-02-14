import CairoGraphics
import MusicTheory

protocol ScaleRenderer {
    func render(scale: Scale) throws -> CairoImage
}
