import D2MessageIO
import D2Permissions
import Utils
import Logging
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@preconcurrency import SwiftSoup

fileprivate let log = Logger(label: "D2Commands.WebCommand")

public class WebCommand: Command {
    public let info = CommandInfo(
        category: .web,
        shortDescription: "Renders a webpage",
        longDescription: "Fetches and renders an arbitrary HTML page using an embed",
        requiredPermissionLevel: .admin
    )
    public let inputValueType: RichValueType = .urls
    public let outputValueType: RichValueType = .embed
    private let converter = DocumentToMarkdownConverter()

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let url = input.asUrls?.first else {
            await output.append(errorText: "Not a valid URL: `\(input)`")
            return
        }
        guard url.scheme == "http" || url.scheme == "https" else {
            await output.append(errorText: "The scheme has to be HTTP or HTTPS!")
            return
        }
        let request = HTTPRequest(url: url)
        do {
            let document: Document = try await request.fetchHTML()
            let formattedOutput = try document.body().map { try self.converter.convert($0, baseURL: url) } ?? "Empty body"
            let splitOutput: [String] = self.splitForEmbed(formattedOutput)

            await output.append(Embed(
                title: try document.title().nilIfEmpty ?? "Web Result",
                description: splitOutput[safely: 0] ?? "Empty output",
                author: Embed.Author(
                    name: url.host ?? url.absoluteString,
                    iconUrl: self.findFavicon(in: document).flatMap { URL(string: $0, relativeTo: url) }
                ),
                url: url,
                fields: splitOutput.dropFirst().enumerated().map { Embed.Field(name: "Page \($0.0 + 1)", value: $0.1) }
            ))
        } catch {
            await output.append(error, errorText: "Could not fetch or parse HTML document")
        }
    }

    private func splitForEmbed(_ str: String) -> [String] {
        let descriptionLength = 2000
        let fieldLength = 900
        var result = [String(str.prefix(descriptionLength))]

        if str.count > descriptionLength {
            result += str.dropFirst(descriptionLength).split(by: fieldLength).prefix(4)
        }

        return result
    }

    private func findFavicon(in document: Document) -> String? {
        return (try? document.select("link[rel*=icon][href*=png]").first()?.attr("href"))
            .flatMap { $0 } // Flatten nested optional from try?
    }
}
