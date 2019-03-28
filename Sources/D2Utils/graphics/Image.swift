import PNG
import Foundation

struct Image {
	var pixels: [PNG.RGBA<UInt8>]
	let size: Vec2<Int>
	
	var width: Int { return size.x }
	var height: Int { return size.y }
	var uncompressed: Result<PNG.Data.Uncompressed> { return .wrap { try .convert(rgba: pixels, size: (width, height), to: .rgba16) } }
	var encoded: Result<Foundation.Data> {
		return uncompressed.map { output in
			var destination = FoundationDataDestination(data: Foundation.Data(capacity: width * height * 4))
			try output.compress(to: &destination, level: 8)
			return destination.data
		}
	}
	
	subscript(pos: Vec2<Int>) -> Color {
		get { return Color(from: pixels[index(of: pos)]) }
		set(newValue) { pixels[index(of: pos)] = newValue.pngRGBA }
	}
	
	private func index(of pos: Vec2<Int>) -> Int {
		return (pos.y * width) + pos.x
	}
}

extension Color {
	var pngRGBA: PNG.RGBA<UInt8> { return PNG.RGBA(red, green, blue, alpha) }
	
	init(from source: PNG.RGBA<UInt8>) {
		red = source.r
		green = source.g
		blue = source.b
		alpha = source.a
	}
}
