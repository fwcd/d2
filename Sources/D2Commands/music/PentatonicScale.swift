struct PentatonicScale: Scale {
    let notes: [Note]

    init(key: Note) {
        notes = [
            key,
            key + .majorSecond,
            key + .majorThird,
            key + .perfectFifth,
            key + .majorSixth
        ]
    }
}
