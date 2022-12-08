import Graphics
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

    func render(ast: ExpressionASTNode) throws -> Image {
        let image = try Image(width: width, height: height)
        let graphics: Graphics = CairoGraphics(fromImage: image)

        try render(ast, to: graphics, at: Vec2(x: Double(width / 2), y: padding), scaledNodeSpacing: nodeSpacing)

        return image
    }

    private func render(_ node: ExpressionASTNode, to graphics: Graphics, at position: Vec2<Double>, scaledNodeSpacing: Double) throws {
        graphics.draw(Text(node.label, withSize: fontSize, at: position, color: color))

        let childs = node.childs
        var childPos = Vec2(x: position.x - ((Double(childs.count - 1) * scaledNodeSpacing) / 2.0), y: position.y + layerSpacing)

        for child in childs {
            graphics.draw(LineSegment(from: position, to: childPos - Vec2(y: fontSize), color: color))
            try render(child, to: graphics, at: childPos, scaledNodeSpacing: scaledNodeSpacing * 0.8)

            childPos = childPos + Vec2(x: scaledNodeSpacing)
        }
    }
}
