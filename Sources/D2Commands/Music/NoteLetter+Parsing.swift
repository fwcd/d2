import Utils
import MusicTheory

extension NoteLetter {
    init?(parsing str: String) {
        self.init(str.uppercased())
    }
}
