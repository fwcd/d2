import D2MessageIO
import D2Permissions
import Utils
import Logging
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SwiftSoup

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

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let url = input.asUrls?.first else {
            output.append(errorText: "Not a valid URL: `\(input)`")
            return
        }
        guard url.scheme == "http" || url.scheme == "https" else {
            output.append(errorText: "The scheme has to be HTTP or HTTPS!")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                output.append(errorText: "An HTTP error occurred: \(error!)")
                return
            }
            guard let data = data else {
                output.append(errorText: "No data returned")
                return
            }
            guard let html = String(data: data, encoding: .utf8) else {
                output.append(errorText: "Could not decode response as UTF-8")
                return
            }

            do {
                let document: Document = try SwiftSoup.parse(html)
                let formattedOutput = try document.body().map { try self.converter.convert($0, baseURL: url) } ?? "Empty body"
                let splitOutput: [String] = self.splitForEmbed(formattedOutput)

                output.append(Embed(
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
                output.append(error, errorText: "An error occurred while parsing the HTML")
            }
        }.resume()
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
