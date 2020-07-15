struct DiatonicMinorScale: Scale {
    let notes: [Note]

    init(key: Note) {
        notes = [
            key,
            key + .majorSecond,
            key + .minorThird,
            key + .perfectFourth,
            key + .perfectFifth,
            key + .minorSixth,
            key + .minorSeventh
        ]
    }
}
