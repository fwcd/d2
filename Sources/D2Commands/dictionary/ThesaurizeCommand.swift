import D2NetAPIs
import Utils

fileprivate let wordPattern = try! Regex(from: "\\w+|\\S+|\\s+")

public class ThesaurizeCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Replaces text with synonyms",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter some text!")
            return
        }

        let words = wordPattern.allGroups(in: input).map { $0[0] }
        let mappingsPromise: Promise<[String: Set<String>], Error> = sequence(promises: Set(words)
            .filter { $0.allSatisfy { $0.isLetter } }
            .map { term in { OpenThesaurusQuery(term: term).perform()
                .map { (term, self.pickSynonyms(for: term, from: $0)) } } })
            .map { Dictionary(uniqueKeysWithValues: $0) }

        mappingsPromise.listen {
            do {
                let mappings = try $0.get()
                let newWords = words.map { mappings[$0]?.randomElement() ?? $0 }
                output.append(newWords.joined())
            } catch {
                output.append(error, errorText: "Could not fetch thesaurus mappings")
            }
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
