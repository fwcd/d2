import Graphics
import MusicTheory

protocol ScaleRenderer {
    func render(scale: Scale) throws -> Image
}
