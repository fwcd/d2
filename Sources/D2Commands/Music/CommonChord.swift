import Utils
import RegexBuilder
import MusicTheory

private let majorSymbols: Set<String> = ["maj", "M"]
private let minorSymbols: Set<String> = ["min", "m"]

nonisolated(unsafe) private let rawQualityPattern = ChoiceOf(nonEmptyComponents: majorSymbols.union(minorSymbols).map { "\($0)" })

/// Matches a chord.
nonisolated(unsafe) private let chordPattern = Regex {
    // 1. group: root note
    Capture { #/[a-zA-Z][b#]?/# }
    // 2. group: quality (lowercased m for 'minor')
    Optionally {
        Capture { rawQualityPattern }
    }
    // 3. group: 'add'
    Optionally {
        Capture { "add" }
    }
    // 4. group: number of the interval: (7 for 'dominant seventh')
    Optionally {
        Capture { #/\d+/# } transform: { Int($0)! }
    }
}

// TODO: Properly conform to Chord once https://github.com/fwcd/swift-music-theory/issues/11 is fixed.
//       Perhaps even upstream it?

/// A (possibly stacked) triad or power chord.
struct CommonChord: Chord, Hashable, CustomStringConvertible {
    let root: NoteClass
    let intervals: [DiatonicInterval]
    let isMinor: Bool

    var noteClasses: [NoteClass] { intervals.map { root + $0 } }
    var description: String { intervals.isEmpty ? "\(noteClasses)" :  "\(root)\(isMinor ? "m" : "")\(intervals.count == 3 ? "" : String(intervals.last!.degrees + 1))" }

    var notes: [Note] { noteClasses.map { Note(noteClass: $0, octave: 0) } }

    init(of str: String) throws {
        guard let parsed = try? chordPattern.firstMatch(in: str) else { throw ChordError.invalidChord(str) }
        guard let root = try? Note(parsing: String(parsed.1)).noteClass else { throw ChordError.invalidRootNote(String(parsed.1)) }
        let quality = String(parsed.2 ?? "")
        let add = parsed.3 != nil
        let number = parsed.4
        let isMajor = majorSymbols.contains(quality)
        let isMinor = minorSymbols.contains(quality) // otherwise assume major
        var additionalIntervals: [DiatonicInterval] = []

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

    init(triad root: NoteClass, isMinor: Bool = false, with additionalIntervals: [DiatonicInterval] = []) {
        self.init(over: root, intervals: [.unison, isMinor ? .minorThird : .majorThird, .perfectFifth] + additionalIntervals, isMinor: isMinor)
    }

    init(powerChord root: NoteClass) {
        self.init(over: root, intervals: [.unison, .perfectFifth])
    }

    private init(over root: NoteClass, intervals: [DiatonicInterval], isMinor: Bool = false) {
        self.root = root
        self.intervals = intervals
        self.isMinor = isMinor
    }

    func advanced(by n: Int) -> CommonChord {
        CommonChord(over: root + .semitones(n), intervals: intervals, isMinor: isMinor)
    }
}
