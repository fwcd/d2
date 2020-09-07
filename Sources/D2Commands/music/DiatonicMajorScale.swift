struct DiatonicMajorScale: Scale, CustomStringConvertible {
    let key: Note

    var description: String { "\(key)" }
    var notes: [Note] { [
        key,
        key + .majorSecond,
        key + .majorThird,
        key + .perfectFourth,
        key + .perfectFifth,
        key + .majorSixth,
        key + .majorSeventh
    ] }

    init(key: Note) {
        self.key = key
    }
}
