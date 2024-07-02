import D2MessageIO
import D2NetAPIs
import Utils

public class ThesaurusCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Looks up a word on OpenThesaurus",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter some text!")
            return
        }

        do {
            let results = try await OpenThesaurusQuery(term: input).perform()
            output.append(Embed(
                title: ":book: Synonym sets from OpenThesaurus",
                description: results.synsets
                    .compactMap { self.markFirst(from: $0.terms.map(\.term)).joined(separator: ", ").nilIfEmpty }
                    .joined(separator: "\n")
                    .nilIfEmpty ?? "_none :(_"
            ))
        } catch {
            output.append(error, errorText: "Could not perform thesaurus query")
        }
    }

    private func markFirst(from strs: [String]) -> [String] {
        (strs.first.map { ["**\($0)**"] } ?? []) + strs.dropFirst()
    }
}
