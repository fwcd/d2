import D2Graphics

protocol ScaleRenderer {
    func render(scale: Scale) throws -> Image
}
