import Foundation
import D2MessageIO
import D2NetAPIs
import Utils

fileprivate let htmlTagPattern = #/<[^>]+>/#

public class DesignQuoteCommand: StringCommand {
    public let info = CommandInfo(
        category: .quote,
        shortDescription: "Fetches a random quote about design",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let quotes = try await QuotesOnDesignQuery().perform()
            guard let quote = quotes.randomElement() else {
                await output.append(errorText: "No quotes found")
                return
            }

            await output.append(Embed(
                title: quote.title.rendered,
                description: quote.content.rendered.replacing(htmlTagPattern, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            ))
        } catch {
            await output.append(error, errorText: "Could not fetch quote")
        }
    }
}
