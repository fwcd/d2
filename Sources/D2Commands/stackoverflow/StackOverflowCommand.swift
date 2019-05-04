import SwiftDiscord
import Foundation
import D2Utils
import D2Permissions
import D2WebAPIs

public class StackOverflowCommand: StringCommand {
	public let description = "Queries StackOverflow"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			try StackOverflowQuery(input: input).start {
				do {
					guard let answer = try $0.get().items?.first else {
						output.append("No answers found")
						return
					}
					output.append(DiscordEmbed(
						title: "StackOverflow Answer",
						description: answer.bodyMarkdown,
						author: answer.owner.map { DiscordEmbed.Author(name: $0.displayName ?? "Unnamed user", iconUrl: $0.profileImage.flatMap { URL(string: $0) }) },
						color: 0xffad0a
					))
				} catch WebApiError.noResults(let msg) {
					output.append(msg)
					print("WebApiError while querying StackOverflow: \(msg)")
				} catch HTTPRequestError.ioError(let err) {
					output.append("An IO error while querying StackOverflow")
					print(err)
				} catch HTTPRequestError.jsonDecodingError(let data) {
					output.append("Could not decode data as JSON")
					print("Could not decode data from StackOverflow request as JSON: \(data)")
				} catch {
					output.append("An asynchronous error occurred while querying StackOverflow")
					print(error)
				}
			}
		} catch {
			output.append("A synchronous error occurred while querying StackOverflow")
			print(error)
		}
	}
}
