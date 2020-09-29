import Utils

enum NoteLetter: Int, CaseIterable, Hashable {
    case c = 0
    case d = 1
    case e = 2
    case f = 3
    case g = 4
    case a = 5
    case b = 6

    private static let mappings: [String: NoteLetter] = [
        "C": .c,
        "D": .d,
        "E": .e,
        "F": .f,
        "G": .g,
        "A": .a,
        "B": .b,
        "H": .b
    ]

    var previous: NoteLetter { return self - 1 }
    var next: NoteLetter { return self + 1 }

    static func of(_ str: String) -> NoteLetter? {
        return mappings[str.uppercased()]
    }

    static func +(lhs: NoteLetter, rhs: Int) -> NoteLetter {
        return NoteLetter(rawValue: (lhs.rawValue + rhs) %% allCases.count)!
    }

    static func -(lhs: NoteLetter, rhs: Int) -> NoteLetter {
        return lhs + (-rhs)
    }
}
