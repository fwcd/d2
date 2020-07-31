import D2NetAPIs
import D2MessageIO

public class ChangeLogCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the latest commits to D2's repo",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        GitHubCommitsQuery(user: "fwcd", repo: "d2").perform().listen {
            do {
                let commits = try $0.get()
                output.append(Embed(
                    title: ":clock: Latest Commits",
                    description: commits
                        .compactMap(\.commit)
                        .map { "[\($0.message.split(separator: "\n").first?.truncate(100, appending: "...").nilIfEmpty ?? "_no message_")](\($0.url))" }
                        .truncate(10)
                        .joined(separator: "\n")
                ))
            } catch {
                output.append(error, errorText: "Could not fetch latest commits")
            }
        }
    }
}
