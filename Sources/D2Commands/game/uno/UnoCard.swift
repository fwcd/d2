import D2Graphics
import D2Utils

public struct UnoCard: Hashable {
	public let color: UnoColor
	public let label: UnoCardLabel
	public var image: Image? { return createImage() }
	
	private func createImage() -> Image? {
		do {
			let size = Vec2<Double>(x: 200.0, y: 280.0)
			let center = Vec2<Double>(x: size.x / 2.0, y: size.y / 2.0)
			let padding = 50.0
			let img = try Image(width: Int(size.x), height: Int(size.y))
			let graphics = CairoGraphics(fromImage: img)
			
			graphics.draw(rect: Rectangle(fromX: 0, y: 0, width: size.x, height: size.y, color: color.color))
			graphics.draw(ellipse: Ellipse(center: center, radius: Vec2(x: size.x * 0.8, y: center.y - padding), rotation: -Double.pi / 4.0, color: Colors.white))
			
			switch label {
				case .number(let n):
					graphics.draw(text: Text(String(n), withSize: size.x * 0.8, at: Vec2(x: size.x * 0.3, y: size.y * 0.7), color: Colors.black))
				default: break // TODO
			}
			
			return img
		} catch {
			print("Error while creating uno card image: \(error)")
			return nil
		}
	}
}
