import D2NetAPIs
import D2Utils

public class ThesaurizeCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Replaces text with synonyms",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let words = input.split(separator: " ").map(String.init)
        let mappingsPromise: Promise<[String: String], Error> = all(promises: Set(words)
            .filter { $0.allSatisfy { $0.isLetter } }
            .map { term in OpenThesaurusQuery(term: term).perform()
                .map { ($0.synsets.randomElement()?.terms.randomElement()?.term)
                    .map { (term, $0) } } })
            .map { Dictionary(uniqueKeysWithValues: $0.compactMap { $0 }) }

        mappingsPromise.listen {
            do {
                let mappings = try $0.get()
                let newWords = words.map { mappings[$0] ?? $0 }
                output.append(newWords.joined(separator: " "))
            } catch {
                output.append(error, errorText: "Could not fetch thesaurus mappings")
            }
        }
    }
}
