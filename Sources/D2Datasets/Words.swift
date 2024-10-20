import Foundation
import Logging

private let log = Logger(label: "D2Datasets.Words")

// TODO: Isolate words to a separate actor too, similar to SyllablesActor
// (potentially even the same one and rename it to DatasetActor or similar)
// We would have to refactor the game framework in D2Commands for that

public enum Words {
    public static let english = loadWords(name: "english")
    public static let german = loadWords(name: "german")
    public static let nouns = loadWords(name: "nouns")
    public static let programmingLanguages = loadWords(name: "programmingLanguages")
    public static let wordleAllowed = loadWords(name: "wordleAllowed")
    public static let wordlePossible = loadWords(name: "wordlePossible")

    private static func loadWords(name: String) -> [String] {
        log.info("Loading \(name) words...")
        return (try? String(contentsOfFile: "Resources/Words/\(name).txt", encoding: .utf8))?.split(separator: "\n").map(String.init) ?? []
    }
}
