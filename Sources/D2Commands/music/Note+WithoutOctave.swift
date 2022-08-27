import MusicTheory

extension Note {
    init(noteClass: NoteClass) {
        self.init(noteClass: noteClass, octave: 0)
    }

    var withoutOctave: Self {
        Self(noteClass: noteClass, octave: 0)
    }
}
