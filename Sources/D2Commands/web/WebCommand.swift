import SwiftDiscord
import D2Permissions
import D2Utils
import Foundation
import SwiftSoup

fileprivate let urlPattern = try! Regex(from: "<?([^>]+)>?")

public class WebCommand: StringCommand {
	public let description = "Renders a web page"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.admin
	private let converter = DocumentToMarkdownConverter()
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let url = urlPattern.firstGroups(in: input).flatMap({ URL(string: $0[1]) }) else {
			output.append("Not a valid URL: `\(input)`")
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				output.append("An HTTP error occurred: \(error!)")
				return
			}
			guard let data = data else {
				output.append("No data returned")
				return
			}
			guard let html = String(data: data, encoding: .utf8) else {
				output.append("Could not decode response as UTF-8")
				return
			}
			
			do {
				let document: Document = try SwiftSoup.parse(html)
				output.append(DiscordEmbed(
					title: try document.title().nilIfEmpty ?? "Web Result",
					description: try document.body().map { try self.converter.convert($0).truncate(1500) } ?? "Empty body",
					author: DiscordEmbed.Author(
						name: url.host ?? input,
						iconUrl: self.findFavicon(in: document).flatMap { URL(string: $0, relativeTo: url) }
					)
				))
			} catch {
				output.append("An error occurred while parsing the HTML")
				print(error)
			}
		}.resume()
	}
	
	private func findFavicon(in document: Document) -> String? {
		return (try? document.select("link[rel*=icon][href*=png]").first()?.attr("href"))
			.flatMap { $0 } // Flatten nested optional from try?
	}
}
