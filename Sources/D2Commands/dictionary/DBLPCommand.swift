import Foundation
import D2NetAPIs
import D2MessageIO

public class DBLPCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Queries the DBLP database",
        longDescription: "Queries the Digital Bibliography & Library Project, a computer science bibliography database",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter a query!")
            return
        }

        DBLPPublicationsQuery(term: input).perform {
            do {
                let result = try $0.get()
                var urlComponents = URLComponents()
                urlComponents.scheme = "https"
                urlComponents.host = "dblp.org"
                urlComponents.path = "/search"
                urlComponents.queryItems = [URLQueryItem(name: "q", value: result.query)]

                output.append(Embed(
                    title: ":books: DBLP Publication Search Results",
                    url: urlComponents.url,
                    fields: Array(result.hits.hit.map {
                        Embed.Field(name: $0.info.title.truncate(250, appending: "..."), value: """
                            Year: \($0.info.year.map { "\($0)" } ?? "?")
                            Type: \($0.info.type ?? "?")
                            Authors: \($0.info.authors?.author.joined(separator: ", ").truncate(50, appending: "...") ?? "anonymous")
                            DOI: \($0.info.doi ?? "?")
                            URL: \($0.info.url ?? "?")
                            """)
                    }.prefix(4))
                ))
            } catch {
                output.append(error, errorText: "Could not perform query")
            }
        }
    }
}
