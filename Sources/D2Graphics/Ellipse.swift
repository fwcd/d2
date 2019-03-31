import D2Utils

public struct Ellipse<T: VecComponent> {
	public let center: Vec2<T>
	public let radius: Vec2<T>
	public let color: Color
	public let isFilled: Bool
	
	public init(centeredAt center: Vec2<T>, radius: Vec2<T>, color: Color = ShapeDefaults.color, isFilled: Bool = ShapeDefaults.isFilled) {
		self.center = center
		self.radius = radius
		self.color = color
		self.isFilled = isFilled
	}
	
	public init(centerX: T, y centerY: T, radiusX: T, y radiusY: T, color: Color = ShapeDefaults.color, isFilled: Bool = ShapeDefaults.isFilled) {
		self.init(centeredAt: Vec2(x: centerX, y: centerY), radius: Vec2(x: radiusX, y: radiusY), color: color, isFilled: isFilled)
	}
	
	public init(centerX: T, y centerY: T, radius: T, color: Color = ShapeDefaults.color, isFilled: Bool = ShapeDefaults.isFilled) {
		self.init(centerX: centerX, y: centerY, radiusX: radius, y: radius, color: color, isFilled: isFilled)
	}
}
