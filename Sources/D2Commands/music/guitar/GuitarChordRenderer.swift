import D2Graphics

struct GuitarChordRenderer: ChordRenderer {
	private let width: Int
	private let height: Int
	private let fgColor: Color
	private let fretboard: GuitarFretboard
	
	init(
		width: Int = 200,
		height: Int = 200,
		fgColor: Color = Colors.white,
		fretboard: GuitarFretboard = GuitarFretboard()
	) {
		self.width = width
		self.height = height
		self.fgColor = fgColor
		self.fretboard = fretboard
	}
	
	func render(chord: Chord) throws -> Image {
		let image = try Image(width: width, height: height)
		var graphics = CairoGraphics(fromImage: image)
		let guitarChord = try GuitarChord(from: chord, on: fretboard)
		
		graphics.draw(Text("Chord"))
		
		return image
	}
}
