import D2NetAPIs
import Utils

fileprivate let wordPattern = #/\w+|\S+|\s+/#

public class ThesaurizeCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Replaces text with synonyms",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter some text!")
            return
        }

        do {
            let words = input.matches(of: wordPattern).map { String($0.output) }
            var mappings: [String: Set<String>] = [:]

            for word in Set(words) where word.allSatisfy(\.isLetter) {
                let results = try await OpenThesaurusQuery(term: word).perform()
                mappings[word] = pickSynonyms(for: word, from: results)
            }

            let newWords = words.map { mappings[$0]?.randomElement() ?? $0 }
            await output.append(newWords.joined())
        } catch {
            await output.append(error, errorText: "Could not fetch thesaurus mappings")
        }
    }

    private func pickSynonyms(for word: String, from results: OpenThesaurusResults) -> Set<String> {
        results.synsets
            .map { Set($0.terms.map(\.term).filter { !$0.contains("...") }) }
            .first { $0.contains(word) && $0.count > 1 }?
            .filter { $0 != word }
            ?? []
    }
}
