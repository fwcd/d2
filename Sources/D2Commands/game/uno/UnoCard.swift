import D2Graphics
import D2Utils

public struct UnoCard: Hashable {
	public let color: UnoColor
	public let label: UnoCardLabel
	public var image: Image? { return createImage() }
	
	public func canBePlaced(onTopOf other: UnoCard) -> Bool {
		return (color == other.color) || (label == other.label)
	}
	
	private func createImage() -> Image? {
		do {
			let intSize = Vec2<Int>(x: 100, y: 140)
			let size = intSize.asDouble
			let center = size / 2.0
			let ellipseX = size.x * 0.6
			let ellipseY = center.y - (size.x / 3)
			let cardPadding = size.x / 12
			let img = try Image(fromSize: intSize)
			var graphics = CairoGraphics(fromImage: img)
			
			graphics.draw(Rectangle(fromX: 0, y: 0, width: size.x, height: size.y, cornerRadius: cardPadding, color: Colors.white))
			graphics.draw(Rectangle(fromX: cardPadding, y: cardPadding, width: size.x - (cardPadding * 2), height: size.y - (cardPadding * 2), cornerRadius: cardPadding, color: color.color))
			graphics.draw(Ellipse(center: center, radius: Vec2(x: ellipseX, y: ellipseY), rotation: -Double.pi / 4.0, color: Colors.white))
			
			switch label {
				case .number(let n):
					graphics.draw(Text(String(n), withSize: size.x * 0.6, at: Vec2(x: size.x * 0.3, y: size.y * 0.65), color: color.color))
				default:
					let icon = try Image(fromPngFile: label.resourcePngPath!)
					let iconSize = Vec2(x: size.x, y: size.x).floored
					graphics.draw(icon, at: center - (iconSize.asDouble / 2), withSize: iconSize)
			}
			
			return img
		} catch {
			print("Error while creating uno card image: \(error)")
			return nil
		}
	}
}
