import PNG
import Foundation

public struct Image {
	private var pixels: [PNG.RGBA<UInt8>]
	public let size: Vec2<Int>
	
	public var width: Int { return size.x }
	public var height: Int { return size.y }
	public var uncompressed: Result<PNG.Data.Uncompressed, Error> { return Result { try .convert(rgba: pixels, size: (width, height), to: .rgba16) } }
	public var encoded: Result<Foundation.Data, Error> {
		return uncompressed.flatMap { output in Result {
			var destination = FoundationDataDestination(data: Foundation.Data(capacity: width * height * 4))
			try output.compress(to: &destination, level: 8)
			return destination.data
		} }
	}
	
	public init(size: Vec2<Int>) {
		self.size = size
		pixels = Array(repeating: PNG.RGBA<UInt8>(0), count: size.x * size.y)
	}
	
	public init(width: Int, height: Int) {
		self.init(size: Vec2(x: width, y: height))
	}
	
	public subscript(pos: Vec2<Int>) -> Color {
		get { return Color(from: pixels[index(of: pos)]) }
		set(newValue) { pixels[index(of: pos)] = newValue.pngRGBA }
	}
	
	private func index(of pos: Vec2<Int>) -> Int {
		return (pos.y * width) + pos.x
	}
}

extension Color {
	public var pngRGBA: PNG.RGBA<UInt8> { return PNG.RGBA(red, green, blue, alpha) }
	
	public init(from source: PNG.RGBA<UInt8>) {
		red = source.r
		green = source.g
		blue = source.b
		alpha = source.a
	}
}
