import D2Utils

public struct Text {
	public let value: String
	public let fontSize: Double
	public let position: Vec2<Double>
	
	public init(value: String, fontSize: Double = 12, position: Vec2<Double> = Vec2(x: 0, y: 0)) {
		self.value = value
		self.fontSize = fontSize
		self.position = position
	}
}
