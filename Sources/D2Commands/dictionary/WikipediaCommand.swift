import Foundation
import D2MessageIO
import D2Permissions
import D2NetAPIs

public class WikipediaCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Queries Wikipedia",
        longDescription: "Fetches a page summary from Wikipedia",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        WikipediaPageQuery(pageName: input).perform().listen {
            switch $0 {
                case .success(let page):
                    output.append(Embed(
                        title: page.displayTitle ?? page.title ?? "No title",
                        description: (page.extract?.prefix(1000)).map { String($0) },
                        thumbnail: (page.thumbnail?.source).flatMap { URL(string: $0) }.map { Embed.Thumbnail(url: $0) },
                        footer: page.description.map { Embed.Footer(text: $0) }
                    ))
                case .failure(let error):
                    output.append(error, errorText: "An error occurred while querying the Wikipedia")
            }
        }
    }
}
