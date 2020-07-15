struct BluesScale: Scale {
    let notes: [Note]

    init(key: Note) {
        notes = [
            key,
            key + .minorThird,
            key + .perfectFourth,
            key + .diminishedFifth,
            key + .perfectFifth,
            key + .minorSeventh
        ]
    }
}
