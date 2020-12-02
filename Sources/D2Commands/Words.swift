public struct Words {
    public static let english = loadWords(name: "english")
    public static let german = loadWords(name: "german")
    public static let nouns = loadWords(name: "nouns")
    public static let programmingLanguages = loadWords(name: "programmingLanguages")

    private static func loadWords(name: String) -> [String] {
        (try? String(contentsOfFile: "Resources/words/\(name).txt", encoding: .utf8))?.split(separator: "\n").map(String.init) ?? []
    }
}
