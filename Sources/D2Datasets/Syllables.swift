import Foundation

nonisolated(unsafe) private let linePattern = #/(?<word>[^,]+),(?<count>\d+)/#

public enum Syllables {
    public static let german = loadSyllables(name: "german")

    private static func loadSyllables(name: String) -> [String: Int] {
        let raw = (try? String(contentsOfFile: "Resources/Syllables/\(name)", encoding: .utf8)) ?? ""
        let lines = raw.split(separator: "\n")
        return Dictionary(uniqueKeysWithValues: lines.compactMap { line in
            (try? linePattern.wholeMatch(in: line)).map { (String($0.word), Int($0.count)!) }
        })
    }
}
