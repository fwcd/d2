import Graphics
import MusicTheory

protocol ChordRenderer {
    func render(chord: Chord) throws -> Image
}
