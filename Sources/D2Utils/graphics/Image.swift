import Cairo
import Foundation

public struct Image {
	private let surface: Surface
	
	public var width: Int { return surface.width }
	public var height: Int { return surface.height }
	public var size: Vec2<Int> { return Vec2(x: width, y: height) }
	
	public init(from surface: Surface) {
		self.surface = surface
	}
}
