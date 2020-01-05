import SwiftDiscord
import Logging
import D2NetAPIs
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
            "get-project": { [unowned self] _, output in output.append("The current project is `\(self.gitLabConfig.value.projectId.map { "\($0)" } ?? "none")`") },
            "pipelines": { [unowned self] _, output in
                try self.fetchPipelines() {
                    guard case let .success(pipelines) = $0 else {
                        guard case let .failure(error) = $0 else { fatalError("Invalid result variant") }
                        log.warning("\(error)")
                        output.append("Could not fetch pipelines")
                        return
                    }
                    output.append(DiscordEmbed(
                        title: ":rocket: Pipelines",
                        fields: pipelines.prefix(5).map {
                            DiscordEmbed.Field(name: "#\($0.id ?? -1)", value: """
                                Status: \($0.statusEmoji) \($0.status ?? "?")
                                Branch: `\($0.ref ?? "?")`
                                Created At: `\($0.createdAt ?? "?")`
                                Updated At: `\($0.updatedAt ?? "?")`
                                """)
                        }
                    ))
                }
            }
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
                } catch GitLabConfigurationError.unspecified(let attr) {
                    output.append("Please specify the \(attr)")
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
    
    private func remoteGitLab() throws -> RemoteGitLab {
        guard let serverHost = gitLabConfig.value.serverHost else { throw GitLabConfigurationError.unspecified("server host") }
        return RemoteGitLab(host: serverHost)
    }
    
    private func fetchPipelines(then: @escaping (Result<[GitLabPipeline], Error>) -> Void) throws {
        guard let projectId = gitLabConfig.value.projectId else { throw GitLabConfigurationError.unspecified("project id") }
        try remoteGitLab().queryPipelines(projectId: projectId, then: then)
    }
}
