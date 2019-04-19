struct NoteInterval {
	let degrees: Int
	let semitones: Int
	
	static let unison = NoteInterval(degrees: 0, semitones: 0)
	static let minorSecond = NoteInterval(degrees: 1, semitones: 1)
	static let majorSecond = NoteInterval(degrees: 1, semitones: 2)
	static let minorThird = NoteInterval(degrees: 2, semitones: 3)
	static let majorThird = NoteInterval(degrees: 2, semitones: 4)
	static let perfectFourth = NoteInterval(degrees: 3, semitones: 5)
	static let perfectFifth = NoteInterval(degrees: 4, semitones: 7)
	static let minorSixth = NoteInterval(degrees: 5, semitones: 8)
	static let majorSixth = NoteInterval(degrees: 5, semitones: 9)
	static let minorSeventh = NoteInterval(degrees: 6, semitones: 10)
	static let majorSeventh = NoteInterval(degrees: 6, semitones: 11)
	static let octave = NoteInterval(degrees: 7, semitones: 12)
	
	prefix static func -(operand: NoteInterval) -> NoteInterval {
		return NoteInterval(degrees: -operand.degrees, semitones: -operand.semitones)
	}
	
	static func octaves(_ count: Int) -> NoteInterval {
		return NoteInterval(degrees: 7 * count, semitones: 12 * count)
	}
}
