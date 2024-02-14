import CairoGraphics

struct PerceptronRenderer {
    private let width: Int
    private let height: Int
    private let plotter: FunctionGraphRenderer

    init(
        width: Int = 300,
        height: Int = 300
    ) {
        self.width = width
        self.height = height
        plotter = FunctionGraphRenderer(width: width, height: height)
    }

    func render(model: inout SingleLayerPerceptron) throws -> CairoImage? {
        guard model.dimensions == 2 else { return nil }

        let graphics = try CairoContext(width: width, height: height)

        plotter.render(to: graphics) { try? model.boundaryY(atX: $0) }

        for (point, output) in model.dataset {
            guard point.count == 2 else { throw MLError.sizeMismatch("Dataset contains point that is not of dimension 2: \(point)") }
            let x = plotter.pixelToFunctionX.inverseApply(point[0])
            let y = plotter.pixelToFunctionY.inverseApply(point[1])
            let color: Color = output > 0.5 ? .yellow : .cyan
            graphics.draw(ellipse: Ellipse(centerX: x, y: y, radius: 3, color: color, isFilled: true))
        }

        let image = try graphics.makeImage()
        return image
    }
}
