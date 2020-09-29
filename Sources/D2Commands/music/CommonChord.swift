import Utils

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

/// A (possibly stacked) triad or power chord.
struct CommonChord: Chord, Hashable, CustomStringConvertible {
    let root: Note
    let intervals: [NoteInterval]
    let isMinor: Bool

    /// The associated scale, either diatonic major or minor
    var scale: Scale { isMinor ? DiatonicMinorScale(key: root) : DiatonicMajorScale(key: root) }
    var notes: [Note] { intervals.map { root + $0 } }
    var description: String { intervals.isEmpty ? "\(notes)" :  "\(root)\(isMinor ? "m" : "")\(intervals.count == 3 ? "" : String(intervals.last!.degrees + 1))" }

    init(of str: String) throws {
        guard let parsed = chordPattern.firstGroups(in: str) else { throw ChordError.invalidChord(str) }
        guard let root = try? Note(of: parsed[1]) else { throw ChordError.invalidRootNote(parsed[1]) }
        let quality = parsed[2]
        let add = !parsed[3].isEmpty
        let number = Int(parsed[4])
        let isMajor = majorSymbols.contains(quality)
        let isMinor = minorSymbols.contains(quality) // otherwise assume major
        var additionalIntervals: [NoteInterval] = []

        switch number {
            case 11:
                additionalIntervals.insert(.perfectEleventh, at: 0)
                if add {
                    self.init(triad: root, isMinor: isMinor, with: additionalIntervals)
                } else { fallthrough }
            case 9:
                additionalIntervals.insert(isMinor ? .minorNinth : .majorNinth, at: 0)
                if add {
                    self.init(triad: root, isMinor: isMinor, with: additionalIntervals)
                } else { fallthrough }
            case 7:
                additionalIntervals.insert(isMajor ? .majorSeventh : .minorSeventh, at: 0)
                self.init(triad: root, isMinor: isMinor, with: additionalIntervals)
            case 5:
                self.init(powerChord: root)
            default:
                self.init(triad: root, isMinor: isMinor)
        }
    }

    init(triad root: Note, isMinor: Bool = false, with additionalIntervals: [NoteInterval] = []) {
        self.init(over: root, intervals: [.unison, isMinor ? .minorThird : .majorThird, .perfectFifth] + additionalIntervals, isMinor: isMinor)
    }

    init(powerChord root: Note) {
        self.init(over: root, intervals: [.unison, .perfectFifth])
    }

    private init(over root: Note, intervals: [NoteInterval], isMinor: Bool = false) {
        self.root = root
        self.intervals = intervals
        self.isMinor = isMinor
    }

    func advanced(by n: Int) -> CommonChord {
        CommonChord(over: root.advanced(by: n).withoutOctave, intervals: intervals, isMinor: isMinor)
    }
}
