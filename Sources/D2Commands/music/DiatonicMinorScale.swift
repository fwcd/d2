struct DiatonicMinorScale: Scale, CustomStringConvertible {
    let key: Note

    var description: String { "\(key)m" }
    var notes: [Note] { [
        key,
        key + .majorSecond,
        key + .minorThird,
        key + .perfectFourth,
        key + .perfectFifth,
        key + .minorSixth,
        key + .minorSeventh
    ] }

    init(key: Note) {
        self.key = key
    }
}
