import D2Graphics
import D2Utils

public struct UnoCard: Hashable {
	public let color: UnoColor
	public let label: UnoCardLabel
	public var image: Image? { return createImage() }
	
	private func createImage() -> Image? {
		do {
			let intSize = Vec2<Int>(x: 200, y: 280)
			let size = intSize.asDouble
			let center = size / 2.0
			let padding = 50.0
			let img = try Image(width: intSize.x, height: intSize.y)
			var graphics = CairoGraphics(fromImage: img)
			
			graphics.draw(Rectangle(fromX: 0, y: 0, width: size.x, height: size.y, color: color.color))
			graphics.draw(Ellipse(center: center, radius: Vec2(x: size.x * 0.8, y: center.y - padding), rotation: -Double.pi / 4.0, color: Colors.white))
			
			switch label {
				case .number(let n):
					graphics.draw(Text(String(n), withSize: size.x * 0.8, at: Vec2(x: size.x * 0.3, y: size.y * 0.7), color: color.color))
				default:
					let icon = try Image(fromPngFile: label.resourcePngPath!)
					let iconSize = Vec2(x: intSize.x, y: intSize.x)
					graphics.draw(icon, at: center - (iconSize.asDouble / 2), withSize: iconSize)
			}
			
			return img
		} catch {
			print("Error while creating uno card image: \(error)")
			return nil
		}
	}
}
