import D2MessageIO
import Foundation
import Logging
import D2Utils
import D2Permissions
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.StackOverflowCommand")

public class StackOverflowCommand: StringCommand {
	public let info = CommandInfo(
		category: .forum,
		shortDescription: "Queries Stack Overflow",
		longDescription: "Searches Stack Overflow using the given input",
		requiredPermissionLevel: .vip
	)

	public init() {}

	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			try StackOverflowQuery(input: input).start().listen {
				do {
					guard let answer = try $0.get().items?.first else {
						output.append(errorText: "No answers found")
						return
					}
					output.append(Embed(
						title: "StackOverflow Answer",
						description: answer.bodyMarkdown,
						author: answer.owner.map { Embed.Author(name: $0.displayName ?? "Unnamed user", iconUrl: $0.profileImage.flatMap { URL(string: $0) }) },
						color: 0xffad0a
					))
				} catch NetApiError.noResults(let msg) {
					output.append(errorText: msg)
					log.warning("NetApiError while querying StackOverflow: \(msg)")
				} catch NetworkError.ioError(let err) {
					output.append(err, errorText: "An IO error while querying StackOverflow")
				} catch NetworkError.jsonDecodingError(let data) {
					output.append(errorText: "Could not decode data as JSON")
					log.warning("Could not decode data from StackOverflow request as JSON: \(data)")
				} catch {
					output.append(error, errorText: "An asynchronous error occurred while querying StackOverflow")
				}
			}
		} catch {
			output.append(error, errorText: "A synchronous error occurred while querying StackOverflow")
		}
	}
}
