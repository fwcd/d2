import MusicTheory

protocol AbbreviatedClassName {
    var abbreviatedClassName: String { get }
}

extension MajorScale: AbbreviatedClassName {
    var abbreviatedClassName: String { "\(key.noteClass)" }
}

extension MinorScale: AbbreviatedClassName {
    var abbreviatedClassName: String { "\(key.noteClass)m" }
}
