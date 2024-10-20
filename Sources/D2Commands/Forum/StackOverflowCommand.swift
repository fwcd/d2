import D2MessageIO
import Foundation
import Logging
import Utils
import D2Permissions
import D2NetAPIs

private let log = Logger(label: "D2Commands.StackOverflowCommand")

public class StackOverflowCommand: StringCommand {
    public let info = CommandInfo(
        category: .forum,
        shortDescription: "Queries Stack Overflow",
        longDescription: "Searches Stack Overflow using the given input",
        presented: true,
        requiredPermissionLevel: .vip
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let results = try await StackOverflowQuery(input: input).perform()
            guard let answer = results.items?.first else {
                await output.append(errorText: "No answers found")
                return
            }
            await output.append(Embed(
                title: "StackOverflow Answer",
                description: answer.bodyMarkdown,
                author: answer.owner.map { Embed.Author(name: $0.displayName ?? "Unnamed user", iconUrl: $0.profileImage.flatMap { URL(string: $0) }) },
                color: 0xffad0a
            ))
        } catch NetApiError.noResults(let msg) {
            await output.append(errorText: msg)
            log.warning("NetApiError while querying StackOverflow: \(msg)")
        } catch NetworkError.ioError(let err) {
            await output.append(err, errorText: "An IO error while querying StackOverflow")
        } catch NetworkError.jsonDecodingError(let data) {
            await output.append(errorText: "Could not decode data as JSON")
            log.warning("Could not decode data from StackOverflow request as JSON: \(data)")
        } catch {
            await output.append(error, errorText: "An error occurred while querying StackOverflow")
        }
    }
}
