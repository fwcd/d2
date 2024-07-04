import D2MessageIO
import D2NetAPIs

public class UniversitiesCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Searches for universities with a name worldwidely",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter a term to search for!")
            return
        }

        do {
            let unis = try await UniversitiesQuery(name: input).perform()
            await output.append(Embed(
                title: ":school: Universities with Name `\(input)`",
                fields: unis.prefix(5).map {
                    Embed.Field(
                        name: $0.name,
                        value: [
                            ("Country", $0.country),
                            ("Web Page", $0.webPages?.first)
                        ].compactMap { (k, v) in v.map { "\(k): \($0)" } }.joined(separator: "\n").nilIfEmpty ?? "_none_"
                    )
                }
            ))
        } catch {
            await output.append(error, errorText: "Could not perform query")
        }
    }
}
