import Logging
import D2MessageIO
import D2Utils
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.HoogleCommand")

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
        HoogleQuery(term: input).perform {
            do {
                let results = try $0.get()
                output.append(Embed(
                    title: ":closed_umbrella: Hoogle Results",
                    color: 0x8900b3,
                    fields: try results
                        .map { Embed.Field(name: "`\(try self.converter.plainTextOf(htmlFragment: $0.item))`", value: """
                            _from \($0.module?.markdown ?? "?") in \($0.package?.markdown ?? "?")_
                            \(try $0.docs.map { try self.converter.convert(htmlFragment: $0.replacingOccurrences(of: "\n", with: "<br>")) } ?? "_no docs_")
                            """) }
                ))
            } catch {
                output.append(error, errorText: "An error occurred while hoogling")
            }
        }
    }
}
