import Foundation
import Logging
import D2MessageIO
import Utils
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.HoogleCommand")
fileprivate let newlines = try! LegacyRegex(from: "\\n+")

fileprivate struct HoogleResultKey: Hashable {
    let item: String
    let renderedDoc: String
}

public class HoogleCommand: StringCommand {
    public let info = CommandInfo(
        category: .programming,
        shortDescription: "Hoogles a type signature",
        longDescription: "Searches for a function matching a type signature using the Hoogle search engine",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    private let converter = DocumentToMarkdownConverter(useMultiLineCodeBlocks: true, codeLanguage: "haskell")

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        HoogleQuery(term: input, count: 50).perform().listen {
            do {
                let searchResults = try $0.get()
                var urlComponents = URLComponents()
                urlComponents.scheme = "https"
                urlComponents.host = "hoogle.haskell.org"
                urlComponents.path = "/"
                urlComponents.queryItems = [URLQueryItem(name: "hoogle", value: input)]

                output.append(Embed(
                    title: ":closed_umbrella: Hoogle Results",
                    url: urlComponents.url,
                    color: 0x8900b3,
                    fields: try Array(searchResults
                        .grouped(by: {
                            HoogleResultKey(
                                item: $0.item,
                                renderedDoc: try $0.docs
                                    .map { try self.converter.convert(htmlFragment: newlines.replace(in: $0, with: "<br>")) }
                                    ?? "_no docs_"
                            )
                        }).map { (key, results) in
                            let name = try self.converter.plainTextOf(htmlFragment: key.item).truncated(to: 250, appending: "...")
                            let modules = results
                                .grouped(by: \.package)
                                .map { "\($0.0?.markdown ?? "?") \($0.1.map { $0.module?.markdown ?? "?" }.truncated(to: 4, appending: "...").joined(separator: " "))" }
                                .truncated(to: 3, appending: "...")
                                .joined(separator: ", ")
                            let doc = key.renderedDoc.truncated(to: 1000 - modules.count, appending: "...")
                            return Embed.Field(
                                name: "`\(name)`",
                                value: """
                                    _\(modules)_
                                    \(doc)
                                    """
                            )
                        }.prefix(4))
                ))
            } catch {
                output.append(error, errorText: "An error occurred while hoogling")
            }
        }
    }
}
