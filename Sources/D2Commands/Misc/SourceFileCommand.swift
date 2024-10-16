import Logging
import Utils
import D2MessageIO
import D2Permissions
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

fileprivate let log = Logger(label: "D2Commands.SourceFileCommand")

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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let command = context.registry[input] else {
            await output.append(errorText: "Unknown command `\(input)`")
            return
        }
        guard let relativeFilePath = command.info.sourceFile.components(separatedBy: "Sources/").last else {
            await output.append(errorText: "Could not locate source file for command `\(input)`")
            return
        }

        let relativeRepoPath = "Sources/\(relativeFilePath)"
        guard let url = URL(string: "\(repositoryUrl)/\(relativeRepoPath)"),
            let rawURL = URL(string: "\(rawRepositoryUrl)/\(relativeRepoPath)") else {
            await output.append(errorText: "Could not create URLs for command `\(input)`")
            return
        }

        do {
            let request = HTTPRequest(url: rawURL)
            let code = try await request.fetchUTF8().prefix(512)

            await output.append(Embed(
                title: relativeFilePath.split(separator: "/").last.map { String($0) } ?? "?",
                description: "```swift\n\(code)\n```",
                url: url
            ))
        } catch {
            await output.append(error, errorText: "Could not query source file")
        }
    }
}
