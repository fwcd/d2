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

struct Chord: Hashable, CustomStringConvertible {
	let notes: [Note]
	var description: String { return notes.description }
	
	init(of str: String) throws {
		guard let parsed = chordPattern.firstGroups(in: str) else { throw ChordError.invalidChord(str) }
		guard let root = try? Note(of: parsed[1]) else { throw ChordError.invalidRootNote(parsed[1]) }
		let quality = parsed[2]
		let number = Int(parsed[3])
		
		if number == 7 {
			if minorSymbols.contains(quality) {
				self.init(minorSeventh: root)
			} else if majorSymbols.contains(quality) {
				self.init(majorSeventh: root)
			} else {
				self.init(dominantSeventh: root)
			}
		} else if minorSymbols.contains(quality) {
			self.init(minorTriad: root)
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
	
	init(minorSeventh root: Note) {
		notes = [root, root + .minorSeventh, root + .perfectFifth, root + .minorSeventh]
	}
	
	init(majorSeventh root: Note) {
		notes = [root, root + .majorThird, root + .perfectFifth, root + .majorSeventh]
	}
	
	init(dominantSeventh root: Note) {
		notes = [root, root + .majorThird, root + .perfectFifth, root + .minorSeventh]
	}
}
