public struct Words {
    public static let english = loadWords(language: "english")
    public static let german = loadWords(language: "german")

    private static func loadWords(language: String) -> Set<String> {
        Set((try? String(contentsOfFile: "Resources/words/\(language).txt", encoding: .utf8))?.split(separator: "\n").map(String.init) ?? [])
    }
}
