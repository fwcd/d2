import Graphics

protocol ChordRenderer {
    func render(chord: Chord) throws -> Image
}
