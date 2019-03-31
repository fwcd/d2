import D2Utils

public struct Ellipse<T: VecComponent> {
	public let center: Vec2<T>
	public let radius: Vec2<T>
	public let color: Color
	public let isFilled: Bool
	public let rotation: T
	
	public init(
		center: Vec2<T> = Vec2(x: 0, y: 0),
		radius: Vec2<T> = Vec2(x: 1, y: 1),
		rotation: T = 0,
		color: Color = ShapeDefaults.color,
		isFilled: Bool = ShapeDefaults.isFilled
	) {
		self.center = center
		self.radius = radius
		self.color = color
		self.isFilled = isFilled
		self.rotation = rotation
	}
	
	public init(
		centerX: T = 0,
		y centerY: T = 0,
		radiusX: T = 1,
		y radiusY: T = 1,
		rotation: T = 0,
		color: Color = ShapeDefaults.color,
		isFilled: Bool = ShapeDefaults.isFilled
	) {
		self.init(center: Vec2(x: centerX, y: centerY), radius: Vec2(x: radiusX, y: radiusY), color: color, isFilled: isFilled)
	}
	
	public init(
		centerX: T = 0,
		y centerY: T = 0,
		radius: T = 1,
		rotation: T = 0,
		color: Color = ShapeDefaults.color,
		isFilled: Bool = ShapeDefaults.isFilled
	) {
		self.init(centerX: centerX, y: centerY, radiusX: radius, y: radius, color: color, isFilled: isFilled)
	}
}
