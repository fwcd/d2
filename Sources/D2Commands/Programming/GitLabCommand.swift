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
    private var subcommands: [String: (String, CommandOutput) async throws -> Void] = [:]

    public init() {
        subcommands = [
            "set-server": { [unowned self] arg, output in
                self.gitLabConfig.serverHost = arg
                await output.append(":white_check_mark: Updated server to `\(arg)`")
            },
            "set-project": { [unowned self] arg, output in
                guard let projectId = Int(arg) else {
                    await output.append(errorText: "Project ID should be an integer: `\(arg)`")
                    return
                }
                self.gitLabConfig.projectId = projectId
                await output.append(":white_check_mark: Updated project to `\(arg)`")
            },
            "get-server": { [unowned self] _, output in await output.append("The current server is `\(self.gitLabConfig.serverHost ?? "none")`") },
            "get-project": { [unowned self] _, output in await output.append("The current project is `\(self.gitLabConfig.projectId.map { "\($0)" } ?? "none")`") },
            "pipelines": { [unowned self] _, output in
                do {
                    let pipelines = try await self.fetchPipelines()
                    await output.append(Embed(
                        title: ":rocket: Pipelines",
                        fields: pipelines.prefix(5).map {
                            Embed.Field(name: "#\($0.id ?? -1)", value: self.describe(pipeline: $0))
                        }
                    ))
                } catch {
                    await output.append(error, errorText: "Could not fetch pipelines")
                }
            },
            "pipeline": { [unowned self] _, output in
                do {
                    let jobs = try await self.fetchMostRecentPipelineJobsAndLogs()
                    let pipeline = jobs.first?.0.pipeline
                    await output.append(Embed(
                        title: ":fireworks: Pipeline #\(pipeline?.id ?? -1) (most recent)",
                        fields: (pipeline.map(self.describe(pipeline:)).map { [Embed.Field(name: "Information", value: $0)] } ?? []) + jobs.map { (job, jobLog) in
                            Embed.Field(name: "Job: \((job.stage ?? "?").withFirstUppercased)", value: self.describe(job: job, withLog: jobLog))
                        }
                    ))
                } catch {
                    await output.append(error, errorText: "Could not fetch most recent pipeline")
                }
            }
        ]
        info.helpText = """
            Subcommands:
            \(subcommands.map { "- `\($0.key)`" }.joined(separator: "\n"))
            """
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if let parsed = try? subcommandPattern.firstMatch(in: input) {
            let subcommandName = String(parsed.name)
            let arg = String(parsed.arg)
            if let subcommand = subcommands[subcommandName] {
                do {
                    try await subcommand(arg, output)
                } catch GitLabConfigurationError.unspecified(let attr) {
                    await output.append(errorText: "Please specify the \(attr)")
                } catch {
                    await output.append(error, errorText: "An error occurred while executing the subcommand")
                }
            } else {
                await output.append(errorText: "Could not find subcommand with name `\(subcommandName)`")
            }
        } else {
            await output.append(errorText: "Please use the following pattern: `[subcommand] [...]`")
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
            case "success"?: ":white_check_mark:"
            case "failed"?: ":x:"
            case "running"?: ":man_running:"
            case "pending"?: ":hourglass:"
            case "cancelled"?: ":no_entry_sign:"
            default: ":question:"
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

    private func fetchPipelines() async throws -> [GitLabPipeline] {
        try await remoteGitLab().fetchPipelines(projectId: projectId())
    }

    private func fetchJobs() async throws -> [GitLabJob] {
        try await remoteGitLab().fetchJobs(projectId: projectId())
    }

    private func fetchMostRecentPipelineJobsAndLogs() async throws -> [(GitLabJob, String)] {
        let jobs = try await fetchJobs()

        let mostRecentPipelineId = jobs.compactMap { $0.pipeline?.id }.max()
        let pipelineJobs = jobs.filter { $0.pipeline?.id == mostRecentPipelineId }
        let sortedJobs = pipelineJobs.sorted(by: ascendingComparator { $0.id ?? -1 })
        let gitLab = try remoteGitLab()
        let pid = try projectId()

        var jobLogs: [String] = []
        for job in sortedJobs {
            if let jid = job.id {
                let jobLog = try await gitLab.fetchJobLog(projectId: pid, jobId: jid)
                jobLogs.append(jobLog)
            } else {
                jobLogs.append("")
            }
        }

        return Array(zip(sortedJobs, jobLogs))
    }
}
