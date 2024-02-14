import D2MessageIO
import Logging
import D2NetAPIs
import D2Permissions
import Utils

fileprivate let log = Logger(label: "D2Commands.GitLabCommand")
fileprivate let subcommandPattern = #/(?<name>[\w-]+)\s*(?<arg>.*)/#

public class GitLabCommand: StringCommand {
    public var info = CommandInfo(
        category: .programming,
        shortDescription: "Queries a GitLab server",
        longDescription: "Fetches CI/CD pipeline information and more from a GitLab server",
        presented: true,
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
                self.fetchPipelines().listen {
                    do {
                        let pipelines = try $0.get()
                        output.append(Embed(
                            title: ":rocket: Pipelines",
                            fields: pipelines.prefix(5).map {
                                Embed.Field(name: "#\($0.id ?? -1)", value: self.describe(pipeline: $0))
                            }
                        ))
                    } catch {
                        output.append(error, errorText: "Could not fetch pipelines")
                    }

                }
            },
            "pipeline": { [unowned self] _, output in
                self.fetchMostRecentPipelineJobsAndLogs().listen {
                    do {
                        let jobs = try $0.get()
                        let pipeline = jobs.first?.0.pipeline
                        output.append(Embed(
                            title: ":fireworks: Pipeline #\(pipeline?.id ?? -1) (most recent)",
                            fields: (pipeline.map(self.describe(pipeline:)).map { [Embed.Field(name: "Information", value: $0)] } ?? []) + jobs.map { (job, jobLog) in
                                Embed.Field(name: "Job: \((job.stage ?? "?").withFirstUppercased)", value: self.describe(job: job, withLog: jobLog))
                            }
                        ))
                    } catch {
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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        if let parsed = try? subcommandPattern.firstMatch(in: input) {
            let subcommandName = String(parsed.name)
            let arg = String(parsed.arg)
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

    private func fetchPipelines() -> Promise<[GitLabPipeline], any Error> {
        Promise.catchingThen { try remoteGitLab().fetchPipelines(projectId: try projectId()) }
    }

    private func fetchJobs() -> Promise<[GitLabJob], any Error> {
        Promise.catchingThen { try remoteGitLab().fetchJobs(projectId: try projectId()) }
    }

    private func fetchMostRecentPipelineJobsAndLogs() -> Promise<[(GitLabJob, String)], any Error> {
        fetchJobs()
            .map { (jobs: [GitLabJob]) -> [GitLabJob] in
                let mostRecentPipelineId = jobs.compactMap { $0.pipeline?.id }.max()
                return jobs.filter { $0.pipeline?.id == mostRecentPipelineId }
            }
            .thenCatching { pipelineJobs in
                let sortedJobs = pipelineJobs.sorted(by: ascendingComparator { $0.id ?? -1 })
                let gitLab = try self.remoteGitLab()
                let pid = try self.projectId()
                return sequence(promises: sortedJobs.map { job in { job.id.map { jid in gitLab.fetchJobLog(projectId: pid, jobId: jid) } ?? Promise(.success("")) } })
                    .map { jobLogs in Array(zip(sortedJobs, jobLogs)) }
            }
    }
}
