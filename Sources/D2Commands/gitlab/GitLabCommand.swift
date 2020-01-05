import SwiftDiscord
import Logging
import D2Permissions
import D2Utils

fileprivate let log = Logger(label: "GitLabCommand")
fileprivate let subcommandPattern = try! Regex(from: "([\\w-]+)\\s*(.*)")

public class GitLabCommand: StringCommand {
    public var info = CommandInfo(
        category: .gitlab,
        shortDescription: "Queries a GitLab server",
        longDescription: "Fetches CI/CD pipeline information and more from a GitLab server",
        requiredPermissionLevel: .vip
    )
    private let gitLabConfig = try! AutoSerializing<GitLabConfiguration>(filePath: "local/gitLabConfig.json")
    private var subcommands: [String: (String, CommandOutput) throws -> Void] = [:]
    
    public init() {
        subcommands = [
            "set-server": { [unowned self] arg, output in
                try self.gitLabConfig.update { $0.serverHost = arg }
                output.append(":white_check_mark: Updated server to `\(arg)`")
            },
            "set-project": { [unowned self] arg, output in
                guard let projectId = Int(arg) else {
                    output.append("Project ID should be an integer: `\(arg)`")
                    return
                }
                try self.gitLabConfig.update { $0.projectId = projectId }
                output.append(":white_check_mark: Updated project to `\(arg)`")
            },
            "get-server": { [unowned self] _, output in output.append("The current server is `\(self.gitLabConfig.value.serverHost ?? "none")`") },
            "get-project": { [unowned self] _, output in output.append("The current project is `\(self.gitLabConfig.value.projectId.map { "\($0)" } ?? "none")`") }
        ]
        info.helpText = """
            Subcommands:
            \(subcommands.map { "- `\($0.key)`" }.joined(separator: "\n"))
            """
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        if let parsed = subcommandPattern.firstGroups(in: input) {
            let subcommandName = parsed[1]
            let arg = parsed[2]
            if let subcommand = subcommands[subcommandName] {
                do {
                    try subcommand(arg, output)
                } catch {
                    output.append("An error occurred while executing the subcommand")
                    log.warning("\(error)")
                }
            } else {
                output.append("Could not find subcommand with name `\(subcommandName)`")
            }
        } else {
            output.append("Please use the following pattern: `[subcommand] [...]`")
        }
    }
}
