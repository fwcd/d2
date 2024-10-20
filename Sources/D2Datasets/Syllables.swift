import Foundation
import Logging

private let log = Logger(label: "D2Datasets.Syllables")
nonisolated(unsafe) private let linePattern = #/^(?<word>[^,]+),(?<count>\d+)/#

@SyllablesActor
public enum Syllables {
    public static let german = loadSyllables(name: "german")

    private static func loadSyllables(name: String) -> [String: Int] {
        log.info("Loading \(name) syllables...")
        let raw = (try? String(contentsOfFile: "Resources/Syllables/\(name).csv", encoding: .utf8)) ?? ""
        let lines = raw.split(separator: "\n")
        return Dictionary(uniqueKeysWithValues: lines.compactMap { line in
            (try? linePattern.firstMatch(in: line)).map { (String($0.word), Int($0.count)!) }
        })
    }
}
