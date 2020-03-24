import Logging
import D2MessageIO
import D2Permissions
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

fileprivate let log = Logger(label: "SourceFileCommand")

fileprivate let repositoryUrl = "https://github.com/fwcd/d2/tree/master"
fileprivate let rawRepositoryUrl = "https://raw.githubusercontent.com/fwcd/d2/master"

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
			output.append(errorText: "Unknown command `\(input)`")
			return
		}
		guard let relativeFilePath = command.info.sourceFile.components(separatedBy: "Sources/").last else {
			output.append(errorText: "Could not locate source file for command `\(input)`")
			return
		}
		
		let relativeRepoPath = "Sources/\(relativeFilePath)"
		guard let url = URL(string: "\(repositoryUrl)/\(relativeRepoPath)"),
			let rawURL = URL(string: "\(rawRepositoryUrl)/\(relativeRepoPath)") else {
			output.append(errorText: "Could not create URLs for command `\(input)`")
			return
		}
		
		// TODO: Use HTTPRequest from D2Utils
		
		var request = URLRequest(url: rawURL)
		request.httpMethod = "GET"
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				log.warning("\(error!)")
				output.append(errorText: "Error while querying source file URL")
				return
			}
			guard let data = data else {
				output.append(errorText: "Missing data after querying source file URL")
				return
			}
			guard let code = String(data: data, encoding: .utf8)?.prefix(512) else {
				output.append(errorText: "Could not decode code as UTF-8")
				return
			}
			
			output.append(Embed(
				title: relativeFilePath.split(separator: "/").last.map { String($0) } ?? "?",
				description: "```swift\n\(code)\n```",
				url: url
			))
		}.resume()
	}
}
