private let files: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h"]

func parseRaw(checkType: String) -> CheckType? {
    switch checkType {
        case "+": .check
        case "#": .checkmate
        default: nil
    }
}

func xOf(file: Character) -> Int? {
    return files.firstIndex(of: file)
}

func yOf(rank: Int) -> Int {
    return 8 - rank
}

func fileOf(x: Int) -> Character? {
    return files[safely: x]
}

func rankOf(y: Int) -> Int {
    return 8 - y
}
