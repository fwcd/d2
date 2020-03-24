import D2MessageIO
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
    @AutoSerializing(filePath: "local/gitLabConfig.json") private var gitLabConfig: GitLabConfiguration = .init()
    private var subcommands: [String: (String, CommandOutput) throws -> Void] = [:]
    
    public init() {
        subcommands = [
            "set-server": { [unowned self] arg, output in
                self.gitLabConfig.serverHost = arg
                output.append(":white_check_mark: Updated server to `\(arg)`")
            },
            "set-project": { [unowned self] arg, output in
                guard let projectId = Int(arg) else {
                    output.append(errorText: "Project ID should be an integer: `\(arg)`")
                    return
                }
                self.gitLabConfig.projectId = projectId
                output.append(":white_check_mark: Updated project to `\(arg)`")
            },
            "get-server": { [unowned self] _, output in output.append("The current server is `\(self.gitLabConfig.serverHost ?? "none")`") },
            "get-project": { [unowned self] _, output in output.append("The current project is `\(self.gitLabConfig.projectId.map { "\($0)" } ?? "none")`") },
            "pipelines": { [unowned self] _, output in
                try self.fetchPipelines() {
                    switch $0 {
                        case .success(let pipelines):
                            output.append(Embed(
                                title: ":rocket: Pipelines",
                                fields: pipelines.prefix(5).map {
                                    Embed.Field(name: "#\($0.id ?? -1)", value: self.describe(pipeline: $0))
                                }
                            ))
                        case .failure(let error):
                            output.append(error, errorText: "Could not fetch pipelines")
                    }
                    
                }
            },
            "pipeline": { [unowned self] _, output in
                try self.fetchMostRecentPipelineJobsAndLogs() {
                    switch $0 {
                        case .success(let jobs):
                            let pipeline = jobs.first?.0.pipeline
                            output.append(Embed(
                                title: ":fireworks: Pipeline #\(pipeline?.id ?? -1) (most recent)",
                                fields: (pipeline.map(self.describe(pipeline:)).map { [Embedname: "Information", value: $0)] } ?? []) + jobs.map { (job, jobLog) in
                                    Embedname: "Job: \((job.stage ?? "?").withFirstUppercased)", value: self.describe(job: job, withLog: jobLog))
                                }
                            ))
                        case .failure(let error):
                            output.append(error, errorText: "Could not fetch most recent pipeline")
                    }
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
                    output.append(errorText: "Please specify the \(attr)")
                } catch {
                    output.append(error, errorText: "An error occurred while executing the subcommand")
                }
            } else {
                output.append(errorText: "Could not find subcommand with name `\(subcommandName)`")
            }
        } else {
            output.append(errorText: "Please use the following pattern: `[subcommand] [...]`")
        }
    }
    
    private func describe(pipeline: GitLabPipeline) -> String {
        let status = pipeline.status
        return """
            Status: \(emojiOf(status: status)) \(status ?? "?")
            Branch: `\(pipeline.ref ?? "?")`
            Created At: `\(pipeline.createdAt ?? "?")`
            Updated At: `\(pipeline.updatedAt ?? "?")`
            """
    }
    
    private func describe(job: GitLabJob, withLog jobLog: String) -> String {
        let status = job.status
        return """
            Status: \(emojiOf(status: status)) \(status ?? "?")
            Duration: \(job.duration ?? 0)
            Runner: \(job.runner?.description ?? "?") (\(job.runner?.status ?? "no status"))
            ```
            \(jobLog.nilIfEmpty?.split { $0.isNewline }.suffix(5).joined(separator: "\n") ?? "no log")
            ```
            """
    }
    
    private func emojiOf(status: String?) -> String {
        switch status {
            case "success"?: return ":white_check_mark:"
            case "failed"?: return ":x:"
            case "running"?: return ":man_running:"
            case "pending"?: return ":hourglass:"
            case "cancelled"?: return ":no_entry_sign:"
            default: return ":question:"
        }
    }
    
    private func remoteGitLab() throws -> RemoteGitLab {
        guard let serverHost = gitLabConfig.serverHost else { throw GitLabConfigurationError.unspecified("server host") }
        return RemoteGitLab(host: serverHost)
    }
    
    private func projectId() throws -> Int {
        guard let projectId = gitLabConfig.projectId else { throw GitLabConfigurationError.unspecified("project id") }
        return projectId
    }
    
    private func fetchPipelines(then: @escaping (Result<[GitLabPipeline], Error>) -> Void) throws {
        try remoteGitLab().fetchPipelines(projectId: try projectId(), then: then)
    }
    
    private func fetchMostRecentPipelineJobsAndLogs(then: @escaping (Result<[(GitLabJob, String)], Error>) -> Void) throws {
        let gitLab = try remoteGitLab()
        let pid = try projectId()
        gitLab.fetchJobs(projectId: pid) {
            switch $0.map({ (jobs: [GitLabJob]) -> [GitLabJob] in
                let mostRecentPipelineId = jobs.compactMap { $0.pipeline?.id }.max()
                return jobs.filter { $0.pipeline?.id == mostRecentPipelineId }
            }) {
                case .success(let pipelineJobs):
                    let sortedJobs = pipelineJobs.sorted(by: ascendingComparator { $0.id ?? -1 })
                    collect(thenables: sortedJobs.map { $0.id.map { jid in { gitLab.fetchJobLog(projectId: pid, jobId: jid, then: $0) } } ?? { $0(.success("")) } }) {
                        then($0.map { jobLogs in Array(zip(sortedJobs, jobLogs)) })
                    }
                case .failure(let error):
                    then(.failure(error))
            }
        }
    }
}
