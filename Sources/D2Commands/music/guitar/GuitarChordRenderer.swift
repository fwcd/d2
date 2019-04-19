import D2Graphics

struct GuitarChordRenderer: ChordRenderer {
	private let width: Int
	private let height: Int
	private let fgColor: Color
	
	init(
		width: Int = 200,
		height: Int = 200,
		fgColor: Color = Colors.white
	) {
		self.width = width
		self.height = height
		self.fgColor = fgColor
	}
	
	func render(chord: Chord) throws -> Image {
		let image = try Image(width: width, height: height)
		var graphics = CairoGraphics(fromImage: image)
		
		graphics.draw(Text("Chord"))
		// TODO
		
		return image
	}
}
