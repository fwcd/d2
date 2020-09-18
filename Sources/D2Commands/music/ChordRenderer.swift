import D2Graphics

protocol ChordRenderer {
    func render(chord: Chord) throws -> Image
}
