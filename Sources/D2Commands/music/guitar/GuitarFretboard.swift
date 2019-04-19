let standardGuitarTuning = ["E2", "A2", "D3", "G3", "B3", "E4"].map { try! Note(of: $0) }

struct GuitarFretboard {
	private let guitarStrings: [[Note]]
	var stringCount: Int { return guitarStrings.count }
	
	init(fretCount: Int = 12, tuning: [Note] = standardGuitarTuning) {
		guitarStrings = tuning.map {
			var fret = [Note]()
			var note = $0
			
			for _ in 0..<fretCount {
				fret.append(note)
				note = note + .minorSecond
			}
			
			return fret
		}
	}
	
	struct Location {
		let guitarString: Int // The string index is zero-indexed
		let fret: Int // The fret is zero-indexed
	}
	
	struct NoteResult {
		let note: Note
		let location: Location
	}
	
	func find(note: Note, on guitarString: Int) -> NoteResult? {
		return guitarStrings[safely: guitarString]?
			.enumerated()
			.map { NoteResult(note: $0.1, location: Location(guitarString: guitarString, fret: $0.0)) }
			.first { note.matches($0.note) }
	}
	
	func find(note: Note) -> NoteResult? {
		return (0..<guitarStrings.count).compactMap { find(note: note, on: $0) }.first
	}
}
