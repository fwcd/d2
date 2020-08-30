import D2MessageIO
import D2NetAPIs

public class ThesaurusCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Looks up a word on OpenThesaurus",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter some text!")
            return
        }

        OpenThesaurusQuery(term: input).perform().listen {
            do {
                let results = try $0.get()
                output.append(Embed(
                    title: "Synonym sets from OpenThesaurus",
                    description: results.synsets
                        .compactMap { $0.terms.map(\.term).joined(separator: ", ").nilIfEmpty }
                        .joined(separator: "\n")
                        .nilIfEmpty ?? "_none :(_"
                ))
            } catch {
                output.append(error, errorText: "Could not perform thesaurus query")
            }
        }
    }
}
