@preconcurrency import CairoGraphics
import MusicTheory

protocol ChordRenderer {
    func render(chord: Chord) throws -> CairoImage
}
