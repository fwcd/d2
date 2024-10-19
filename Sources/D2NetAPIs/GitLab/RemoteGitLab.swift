import Utils
import Foundation
import Logging

fileprivate let log = Logger(label: "D2NetAPIs.RemoteGitLab")
fileprivate let apiPath = "/api/v4"

public struct RemoteGitLab: Sendable {
    private let scheme: String
    private let host: String

    public init(scheme: String = "https", host: String) {
        self.scheme = scheme
        self.host = host
    }

    private func request(for endpointPath: String) throws -> HTTPRequest {
        let headers = storedNetApiKeys?.gitlab.map { ["Private-Token": $0] } ?? [:]
        return try HTTPRequest(scheme: scheme, host: host, path: apiPath + endpointPath, headers: headers)
    }

    private func fetchString(from endpointPath: String) async throws -> String {
        log.info("Querying \(endpointPath) from GitLab \(host)")
        return try await request(for: endpointPath).fetchUTF8()
    }

    private func fetchJSON<T>(as type: T.Type, from endpointPath: String) async throws -> T where T: Decodable & Sendable {
        log.info("Querying \(endpointPath) as JSON from GitLab \(host)")
        return try await request(for: endpointPath).fetchJSON(as: type)
    }

    public func fetchPipelines(projectId: Int) async throws -> [GitLabPipeline] {
        try await fetchJSON(as: [GitLabPipeline].self, from: "/projects/\(projectId)/pipelines")
    }

    public func fetchPipeline(projectId: Int, pipelineId: Int) async throws -> GitLabPipeline {
        try await fetchJSON(as: GitLabPipeline.self, from: "/projects/\(projectId)/pipelines/\(pipelineId)")
    }

    public func fetchPipelineJobs(projectId: Int, pipelineId: Int) async throws -> [GitLabJob] {
        try await fetchJSON(as: [GitLabJob].self, from: "/projects/\(projectId)/pipelines/\(pipelineId)/jobs")
    }

    public func fetchJobs(projectId: Int) async throws -> [GitLabJob] {
        try await fetchJSON(as: [GitLabJob].self, from: "/projects/\(projectId)/jobs")
    }

    public func fetchJobLog(projectId: Int, jobId: Int) async throws -> String {
        try await fetchString(from: "/projects/\(projectId)/jobs/\(jobId)/trace")
    }
}
