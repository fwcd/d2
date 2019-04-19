fileprivate func findDots<C: Collection>(remainingNotes: C, usedStrings: [Int] = [], on fretboard: GuitarFretboard) -> [GuitarFretboard.Location]? where C.Element == Note {
	guard let firstNote = remainingNotes.first else { return [] }
	print("Remaining \(remainingNotes)")
	
	for stringIndex in 0..<fretboard.stringCount {
		if !usedStrings.contains(stringIndex), let pos = fretboard.find(note: firstNote, on: stringIndex) {
			if let nextDots = findDots(remainingNotes: remainingNotes.dropFirst(), usedStrings: usedStrings + [stringIndex], on: fretboard) {
				return [pos.location] + nextDots
			}
		}
	}
	
	return nil
}

struct GuitarChord {
	let dots: [GuitarFretboard.Location]
	var maxFret: Int { return dots.map { $0.fret }.max() ?? 0 }
	
	init(dots: [GuitarFretboard.Location]) {
		self.dots = dots
	}
	
	init(from chord: Chord, on fretboard: GuitarFretboard) throws {
		guard let dots = findDots(remainingNotes: chord.notes, on: fretboard) else { throw GuitarError.noGuitarChordFound(chord) }
		self.dots = dots
	}
}
