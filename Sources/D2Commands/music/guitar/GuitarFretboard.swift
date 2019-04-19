let standardGuitarTuning = [try! Note(of: "E4"), try! Note(of: "B3"), try! Note(of: "G3"), try! Note(of: "D3"), try! Note(of: "A2"), try! Note(of: "E2")]

struct GuitarFretboard {
	private let guitarStrings: [[Note]]
	
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
	
	struct NoteResult {
		let note: Note
		let guitarString: Int // The string index is zero-indexed
		let fret: Int // The fret is zero-indexed
	}
	
	func find(note: Note, on guitarString: Int) -> NoteResult? {
		return guitarStrings[safely: guitarString]?
			.enumerated()
			.map { NoteResult(note: $0.1, guitarString: guitarString, fret: $0.0) }
			.first { note.matches($0.note) }
	}
	
	func find(note: Note) -> NoteResult? {
		return (0..<guitarStrings.count).compactMap { find(note: note, on: $0) }.first
	}
}
