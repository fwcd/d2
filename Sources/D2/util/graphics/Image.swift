import PNG

struct Image {
	var pixels: [PNG.RGBA<UInt8>]
	let width: Int
	let height: Int
	
	subscript(y: Int, x: Int) -> Color {
		get { return Color(from: pixels[index(ofY: y, x: x)]) }
		set(newValue) { pixels[index(ofY: y, x: x)] = newValue.pngRGBA }
	}
	
	private func index(ofY y: Int, x: Int) -> Int {
		return (y * width) + x
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
