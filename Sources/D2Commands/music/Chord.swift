import D2Utils

fileprivate let majorSymbols: Set<String> = ["maj", "M"]
fileprivate let minorSymbols: Set<String> = ["min", "m"]

fileprivate let rawQualityPattern = majorSymbols.union(minorSymbols).map { "(?:\($0))" }.joined(separator: "|")

/**
 * Matches a chord.
 *
 * 1. group: root note
 * 2. group: quality (lowercased m for 'minor')
 * 3. group: number of the interval: (7 for 'dominant seventh')
 */
fileprivate let chordPattern = try! Regex(from: "([a-zA-Z][b#]?)(\(rawQualityPattern))?(7)?")

struct Chord: Hashable {
	let notes: [Note]
	
	init(of str: String) throws {
		guard let parsed = chordPattern.firstGroups(in: str) else { throw MusicParseError.invalidChord(str) }
		guard let root = Note(of: parsed[1]) else { throw MusicParseError.invalidRootNote(parsed[1]) }
		let quality = parsed[2]
		let number = Int(parsed[3])
		
		if minorSymbols.contains(quality) {
			self.init(minorTriad: root)
		} else if majorSymbols.contains(quality) && number == 7 {
			self.init(dominantSeventh: root)
		} else { // assume major
			self.init(majorTriad: root)
		}
	}
	
	init(majorTriad root: Note) {
		notes = [root, root + .majorThird, root + .perfectFifth]
	}
	
	init(minorTriad root: Note) {
		notes = [root, root + .minorThird, root + .perfectFifth]
	}
	
	init(dominantSeventh root: Note) {
		notes = [root, root + .majorThird, root + .perfectFifth, root + .minorSeventh]
	}
}
