import D2Graphics
import D2Utils

struct PianoRenderer: ScaleRenderer {
    private let width: Int
    private let height: Int

    init(
        width: Int = 200,
        height: Int = 100
    ) {
        self.width = width
        self.height = height
    }

	func render(scale: Scale) throws -> Image {
        let image = try Image(width: width, height: height)
        var graphics = CairoGraphics(fromImage: image)

        // TODO

        return image
    }
}
