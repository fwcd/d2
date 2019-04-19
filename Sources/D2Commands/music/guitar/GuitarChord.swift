struct GuitarChord {
	let dots: [GuitarFretboard.Location]
	
	init(dots: [GuitarFretboard.Location]) {
		self.dots = dots
	}
	
	init(from chord: Chord, on fretboard: GuitarFretboard) throws {
		// TODO
		throw ChordError.notOnGuitarFretboard(chord)
	}
}
