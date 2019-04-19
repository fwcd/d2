import D2Graphics
import D2Utils

struct GuitarChordRenderer: ChordRenderer {
	private let width: Int
	private let height: Int
	private let padding: Double
	private let fgColor: Color
	private let fretboard: GuitarFretboard
	private let minFrets: Int
	
	init(
		width: Int = 200,
		height: Int = 200,
		padding: Double = 20,
		fgColor: Color = Colors.white,
		fretboard: GuitarFretboard = GuitarFretboard(),
		minFrets: Int = 5
	) {
		self.width = width
		self.height = height
		self.padding = padding
		self.fgColor = fgColor
		self.fretboard = fretboard
		self.minFrets = minFrets
	}
	
	func render(chord: Chord) throws -> Image {
		let image = try Image(width: width, height: height)
		var graphics = CairoGraphics(fromImage: image)
		let guitarChord = try GuitarChord(from: chord, on: fretboard)
		let fretCount = max(minFrets, guitarChord.maxFret)
		let stringCount = fretboard.stringCount
		
		let innerWidth = Double(width) - (padding * 2)
		let innerHeight = Double(height) - (padding * 2)
		let stringSpacing = innerWidth / Double(stringCount - 1)
		let fretSpacing = innerHeight / Double(fretCount - 1)
		let topLeft = Vec2(x: padding, y: padding)
		
		graphics.draw(Rectangle(topLeft: topLeft, size: Vec2(x: innerWidth, y: 10), color: fgColor, isFilled: true))
		
		for stringIndex in 0..<stringCount {
			let position = topLeft + Vec2(x: stringSpacing * Double(stringIndex))
			graphics.draw(LineSegment(from: position, to: position + Vec2(y: innerHeight), color: fgColor))
		}
		
		for fretIndex in 0..<fretCount {
			let position = topLeft + Vec2(y: fretSpacing * Double(fretIndex))
			graphics.draw(LineSegment(from: position, to: position + Vec2(x: innerWidth), color: fgColor))
		}
		
		return image
	}
}
