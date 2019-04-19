fileprivate func cost<C: Collection>(of dots: C) -> Int where C.Element == GuitarFretboard.Location {
	return dots.map { ($0.fret * $0.fret) - $0.guitarString }.reduce(0, +)
}

fileprivate func findDots<C: Collection>(remainingNotes: C, usedStrings: [Int] = [], on fretboard: GuitarFretboard) -> [GuitarFretboard.Location]? where C.Element == Note {
	guard let firstNote = remainingNotes.first else { return [] }
	var bestResult: [GuitarFretboard.Location]? = nil
	var bestCost = Int.max
	
	for stringIndex in 0..<fretboard.stringCount {
		if !usedStrings.contains(stringIndex), let pos = fretboard.find(note: firstNote, on: stringIndex) {
			if let nextDots = findDots(remainingNotes: remainingNotes.dropFirst(), usedStrings: usedStrings + [stringIndex], on: fretboard) {
				let dots = [pos.location] + nextDots
				let currentCost = cost(of: dots)
				
				if currentCost < bestCost {
					bestResult = dots
					bestCost = currentCost
				}
			}
		}
	}
	
	return bestResult
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
