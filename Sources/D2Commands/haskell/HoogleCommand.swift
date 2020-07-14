import Logging
import D2MessageIO
import D2Utils
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.HoogleCommand")
fileprivate let newlines = try! Regex(from: "\\n+")

fileprivate struct HoogleResultKey: Hashable {
    let item: String
    let renderedDoc: String
}

public class HoogleCommand: StringCommand {
    public let info = CommandInfo(
        category: .haskell,
        shortDescription: "Hoogles a type signature",
        longDescription: "Searches for a function matching a type signature using the Hoogle search engine",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    private let converter = DocumentToMarkdownConverter(useMultiLineCodeBlocks: true, codeLanguage: "haskell")
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        HoogleQuery(term: input, count: 15).perform {
            do {
                let searchResults = try $0.get()
                output.append(Embed(
                    title: ":closed_umbrella: Hoogle Results",
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
                            Embed.Field(name: "`\(try self.converter.plainTextOf(htmlFragment: key.item).truncate(250, appending: "..."))`", value: """
                            _from \(results.map { "\($0.module?.markdown ?? "?") in \($0.package?.markdown ?? "?")" }.truncate(3, appending: "...").joined(separator: ", "))_
                            \(key.renderedDoc.truncate(1000, appending: "..."))
                            """)
                        }.prefix(4))
                ))
            } catch {
                output.append(error, errorText: "An error occurred while hoogling")
            }
        }
    }
}
