import Utils
@preconcurrency import CairoGraphics

struct CodenamesBoardView {
    let image: CairoImage

    init(model: CodenamesBoardModel, allUncovered: Bool = false) throws {
        let intPadding = 5
        let padding = Double(intPadding)
        let fieldIntSize = Vec2<Int>(x: 100, y: 50)
        let fieldSize = fieldIntSize.asDouble
        let intSize = (fieldIntSize + Vec2<Int>(both: intPadding)) * Vec2<Int>(x: model.width, y: model.height)

        let image = try CairoImage(size: intSize)
        let graphics = CairoContext(image: image)

        for y in 0..<model.height {
            for x in 0..<model.width {
                var card = model[y, x]
                card.hidden = card.hidden && !allUncovered

                let color = Self.colorOf(card: card)
                let modelPos = Vec2(x: x, y: y)
                let viewPos = (modelPos * (fieldIntSize + Vec2(both: intPadding))).asDouble
                graphics.draw(rect: Rectangle(fromX: viewPos.x, y: viewPos.y, width: fieldSize.x, height: fieldSize.y, color: color))
                graphics.draw(text: Text(card.word, at: viewPos + Vec2(both: padding) + Vec2(y: fieldSize.y / 3), color: .black))
            }
        }

        self.image = image
    }

    private static func colorOf(card: CodenamesBoardModel.Card) -> Color {
        if card.hidden {
            Color(rgb: 0xe0e0e0)
        } else {
            switch card.agent {
                case .team(.red): Color(rgb: 0xad2a10)
                case .team(.blue): Color(rgb: 0x101dad)
                case .innocent: Color(rgb: 0xf5efc6)
                case .assasin: .black
            }
        }
    }
}
