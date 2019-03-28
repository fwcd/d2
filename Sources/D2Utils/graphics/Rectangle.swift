public struct Rectangle<T: VecComponent> {
	public let start: Vec2<T>
	public let end: Vec2<T>
	public let color: Color
	public let isFilled: Bool
}
