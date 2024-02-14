import CairoGraphics
import Utils

struct ASTRenderer {
    private let width: Int
    private let height: Int
    private let fontSize: Double
    private let padding: Double
    private let nodeSpacing: Double
    private let layerSpacing: Double
    private let color: Color

    init(
        width: Int = 200,
        height: Int = 200,
        fontSize: Double = 14.0,
        padding: Double = 10.0,
        nodeSpacing: Double = 50.0,
        layerSpacing: Double = 30.0,
        color: Color = .white
    ) {
        self.width = width
        self.height = height
        self.fontSize = fontSize
        self.padding = padding
        self.nodeSpacing = nodeSpacing
        self.layerSpacing = layerSpacing
        self.color = color
    }

    func render(ast: any ExpressionASTNode) throws -> CairoImage {
        let graphics = try CairoContext(width: width, height: height)

        try render(ast, to: graphics, at: Vec2(x: Double(width / 2), y: padding), scaledNodeSpacing: nodeSpacing)

        return try graphics.makeImage()
    }

    private func render(_ node: any ExpressionASTNode, to graphics: some GraphicsContext, at position: Vec2<Double>, scaledNodeSpacing: Double) throws {
        graphics.draw(text: Text(node.label, withSize: fontSize, at: position, color: color))

        let childs = node.childs
        var childPos = Vec2(x: position.x - ((Double(childs.count - 1) * scaledNodeSpacing) / 2.0), y: position.y + layerSpacing)

        for child in childs {
            graphics.draw(line: LineSegment(from: position, to: childPos - Vec2(y: fontSize), color: color))
            try render(child, to: graphics, at: childPos, scaledNodeSpacing: scaledNodeSpacing * 0.8)

            childPos = childPos + Vec2(x: scaledNodeSpacing)
        }
    }
}
