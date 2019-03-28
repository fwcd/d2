public struct RectangleDefaults {
	public static let color = Colors.white
	public static let isFilled = true
}

public struct Rectangle<T: VecComponent> {
	public let topLeft: Vec2<T>
	public let size: Vec2<T>
	public let color: Color
	public let isFilled: Bool
	
	public var topRight: Vec2<T> { return topLeft + Vec2(x: size.x, y: 0) }
	public var bottomLeft: Vec2<T> { return topLeft + Vec2(x: 0, y: size.y) }
	public var bottomRight: Vec2<T> { return topLeft + size }
	
	public init(topLeft: Vec2<T>, size: Vec2<T>, color: Color = RectangleDefaults.color, isFilled: Bool = RectangleDefaults.isFilled) {
		self.topLeft = topLeft
		self.size = size
		self.color = color
		self.isFilled = isFilled
	}
	
	public init(fromX x: T, y: T, width: T, height: T, color: Color = RectangleDefaults.color, isFilled: Bool = RectangleDefaults.isFilled) {
		self.init(topLeft: Vec2(x: x, y: y), size: Vec2(x: width, y: height), color: color, isFilled: isFilled)
	}
}

extension Rectangle: Sequence where T: Comparable {
	public typealias Element = Vec2<T>
	
	public func makeIterator() -> Iterator {
		return Iterator(from: topLeft, to: bottomRight)
	}
	
	public struct Iterator: IteratorProtocol {
		private let start: Vec2<T>
		private let end: Vec2<T>
		private var current: Vec2<T>?
		
		init(from start: Vec2<T>, to end: Vec2<T>) {
			self.start = start
			self.end = end
			current = start
		}
		
		public mutating func next() -> Vec2<T>? {
			guard let pos = current else { return nil }
			
			if pos.x < end.x {
				current = Vec2(x: pos.x + 1, y: pos.y)
			} else if pos.y < end.y {
				current = Vec2(x: start.x, y: pos.y + 1)
			} else {
				current = nil
			}
			
			return pos
		}
	}
}
