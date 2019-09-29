import SwiftDiscord
import D2Permissions
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

fileprivate let repositoryUrl = "https://github.com/fwcd/D2/tree/master"
fileprivate let rawRepositoryUrl = "https://raw.githubusercontent.com/fwcd/D2/master"

public class SourceFileCommand: StringCommand {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Fetches the source file of a given command",
		longDescription: "Looks up the source code of a command on D2's GitHub repository",
		requiredPermissionLevel: .basic
	)
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let command = context.registry[input] else {
			output.append("Unknown command `\(input)`")
			return
		}
		guard let relativeFilePath = command.info.sourceFile.components(separatedBy: "Sources/").last else {
			output.append("Could not locate source file for command `\(input)`")
			return
		}
		
		let relativeRepoPath = "Sources/\(relativeFilePath)"
		guard let url = URL(string: "\(repositoryUrl)/\(relativeRepoPath)"),
			let rawURL = URL(string: "\(rawRepositoryUrl)/\(relativeRepoPath)") else {
			output.append("Could not create URLs for command `\(input)`")
			return
		}
		
		// TODO: Use HTTPRequest from D2Utils
		
		var request = URLRequest(url: rawURL)
		request.httpMethod = "GET"
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				print(String(describing: error))
				output.append("Error while querying source file URL")
				return
			}
			guard let data = data else {
				output.append("Missing data after querying source file URL")
				return
			}
			guard let code = String(data: data, encoding: .utf8)?.prefix(512) else {
				output.append("Could not decode code as UTF-8")
				return
			}
			
			output.append(DiscordEmbed(
				title: relativeFilePath.split(separator: "/").last.map { String($0) } ?? "?",
				description: "```swift\n\(code)\n```",
				url: url
			))
		}.resume()
	}
}
