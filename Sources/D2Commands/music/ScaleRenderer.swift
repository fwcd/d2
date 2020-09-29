import Graphics

protocol ScaleRenderer {
    func render(scale: Scale) throws -> Image
}
