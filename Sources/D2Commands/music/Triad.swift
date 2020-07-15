import D2Utils

fileprivate let majorSymbols: Set<String> = ["maj", "M"]
fileprivate let minorSymbols: Set<String> = ["min", "m"]

fileprivate let rawQualityPattern = majorSymbols.union(minorSymbols).map { "\($0)" }.joined(separator: "|")

/**
 * Matches a chord.
 *
 * 1. group: root note
 * 2. group: quality (lowercased m for 'minor')
 * 3. group: 'add'
 * 4. group: number of the interval: (7 for 'dominant seventh')
 */
fileprivate let chordPattern = try! Regex(from: "([a-zA-Z][b#]?)(\(rawQualityPattern))?(add)?(\\d+)?")

struct Triad: Chord, Hashable, CustomStringConvertible {
	let notes: [Note]
	var description: String { return notes.description }
	
	init(of str: String) throws {
		guard let parsed = chordPattern.firstGroups(in: str) else { throw ChordError.invalidChord(str) }
		guard let root = try? Note(of: parsed[1]) else { throw ChordError.invalidRootNote(parsed[1]) }
		let quality = parsed[2]
		let add = !parsed[3].isEmpty
		let number = Int(parsed[4])
		let isMajor = majorSymbols.contains(quality)
		let isMinor = minorSymbols.contains(quality) // otherwise assume major
		var additionalNotes: [Note] = []
		
		switch number {
			case 11:
				additionalNotes.insert(root + .perfectEleventh, at: 0)
				if add {
					self.init(triad: root, isMinor: isMinor, with: additionalNotes)
				} else { fallthrough }
			case 9:
				additionalNotes.insert(root + (isMinor ? .minorNinth : .majorNinth), at: 0)
				if add {
					self.init(triad: root, isMinor: isMinor, with: additionalNotes)
				} else { fallthrough }
			case 7:
				additionalNotes.insert(root + (isMajor ? .majorSeventh : .minorSeventh), at: 0)
				self.init(triad: root, isMinor: isMinor, with: additionalNotes)
			case 5:
				self.init(powerChord: root)
			default:
				self.init(triad: root, isMinor: isMinor)
		}
	}
	
	init(triad root: Note, isMinor: Bool = false, with additionalNotes: [Note] = []) {
		notes = [root, root + (isMinor ? .minorThird : .majorThird), root + .perfectFifth] + additionalNotes
	}
	
	init(powerChord root: Note) {
		notes = [root, root + .perfectFifth]
	}
}
