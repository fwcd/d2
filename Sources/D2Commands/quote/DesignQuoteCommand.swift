import Foundation
import D2MessageIO
import D2NetAPIs
import Utils

fileprivate let htmlTagPattern = try! Regex(from: "<[^>]+>")

public class DesignQuoteCommand: StringCommand {
    public let info = CommandInfo(
        category: .quote,
        shortDescription: "Fetches a random quote about design",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        QuotesOnDesignQuery().perform().listen {
            do {
                let quotes = try $0.get()
                guard let quote = quotes.randomElement() else {
                    output.append(errorText: "No quotes found")
                    return
                }

                output.append(Embed(
                    title: quote.title.rendered,
                    description: htmlTagPattern.replace(in: quote.content.rendered, with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                ))
            } catch {
                output.append(error, errorText: "Could not fetch quote")
            }
        }
    }
}
