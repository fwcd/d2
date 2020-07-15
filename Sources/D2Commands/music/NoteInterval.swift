struct NoteInterval {
	let degrees: Int
	let semitones: Int
	
	// Main intervals
	static let unison = NoteInterval(degrees: 0, semitones: 0)
	static let minorSecond = NoteInterval(degrees: 1, semitones: 1)
	static let majorSecond = NoteInterval(degrees: 1, semitones: 2)
	static let minorThird = NoteInterval(degrees: 2, semitones: 3)
	static let majorThird = NoteInterval(degrees: 2, semitones: 4)
	static let perfectFourth = NoteInterval(degrees: 3, semitones: 5)
	static let diminishedFifth = NoteInterval(degrees: 4, semitones: 6)
	static let perfectFifth = NoteInterval(degrees: 4, semitones: 7)
	static let minorSixth = NoteInterval(degrees: 5, semitones: 8)
	static let majorSixth = NoteInterval(degrees: 5, semitones: 9)
	static let minorSeventh = NoteInterval(degrees: 6, semitones: 10)
	static let majorSeventh = NoteInterval(degrees: 6, semitones: 11)
	static let octave = NoteInterval(degrees: 7, semitones: 12)
	
	// Main compound intervals
	static let minorNinth = NoteInterval(degrees: 8, semitones: 13)
	static let majorNinth = NoteInterval(degrees: 8, semitones: 14)
	static let minorTenth = NoteInterval(degrees: 9, semitones: 15)
	static let majorTenth = NoteInterval(degrees: 9, semitones: 16)
	static let perfectEleventh = NoteInterval(degrees: 10, semitones: 17)
	static let perfectTwelfth = NoteInterval(degrees: 11, semitones: 19) // also called 'tritave'
	static let minorThirteenth = NoteInterval(degrees: 12, semitones: 20)
	static let majorThirteenth = NoteInterval(degrees: 12, semitones: 21)
	static let minorFourteenth = NoteInterval(degrees: 13, semitones: 22)
	static let majorFourteenth = NoteInterval(degrees: 13, semitones: 23)
	static let doubleOctave = NoteInterval(degrees: 14, semitones: 24)
	
	prefix static func -(operand: NoteInterval) -> NoteInterval {
		return NoteInterval(degrees: -operand.degrees, semitones: -operand.semitones)
	}
	
	static func octaves(_ count: Int) -> NoteInterval {
		return NoteInterval(degrees: 7 * count, semitones: 12 * count)
	}
}
