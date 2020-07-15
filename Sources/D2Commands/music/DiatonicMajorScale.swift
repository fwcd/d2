struct DiatonicMajorScale: Scale {
    let notes: [Note]

    init(key: Note) {
        notes = [
            key,
            key + .majorSecond,
            key + .majorThird,
            key + .perfectFourth,
            key + .perfectFifth,
            key + .majorSixth,
            key + .majorSeventh
        ]
    }
}
