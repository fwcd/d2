fileprivate func cost(ofLocation location: Fretboard.Location) -> Int {
    return (location.fret * location.fret) - location.guitarString
}

/// Assigns a value to a finger placement. Lower frets, higher strings and more dots are better (thus results in a lower value).
fileprivate func cost<C: Collection>(of dots: C) -> Int where C.Element == Fretboard.Location {
    return dots.map { cost(ofLocation: $0) }.reduce(0, +) + dots.count
}

/// Finds the best finger placement for a given chord (described by the remaining notes).
fileprivate func findDots<C: Collection>(remainingNotes: C, usedStrings: [Int] = [], on fretboard: Fretboard) -> [Fretboard.Location]? where C.Element == Note {
    guard let firstNote = remainingNotes.first else { return [] }
    var bestResult: [Fretboard.Location]? = nil
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

/// Adds additional notes to the chord, provided they are not too unconveniently located.
fileprivate func extend<C: Collection, D: Collection>(dots: C, notes: D, on fretboard: Fretboard, fretThreshold: Int = 5) -> [Fretboard.Location] where C.Element == Fretboard.Location, D.Element == Note {
    var unusedStrings = Set(0..<fretboard.stringCount)

    for dot in dots {
        unusedStrings.remove(dot.guitarString)
    }

    return dots + unusedStrings
        .compactMap { stringIndex in notes.compactMap { fretboard.find(note: $0, on: stringIndex)?.location }.min { cost(ofLocation: $0) < cost(ofLocation: $1) } }
        .filter { $0.fret < fretThreshold }
}

struct FretboardChord {
    let dots: [Fretboard.Location]
    var maxFret: Int { return dots.map { $0.fret }.max() ?? 0 }

    init(dots: [Fretboard.Location]) {
        self.dots = dots
    }

    init(from chord: Chord, on fretboard: Fretboard) throws {
        guard let baseDots = findDots(remainingNotes: chord.notes, on: fretboard) else { throw FretboardChordError.noFretboardChordFound(chord) }
        dots = extend(dots: baseDots, notes: chord.notes, on: fretboard)
    }
}
