import D2Utils
import Foundation
import Logging

fileprivate let log = Logger(label: "RemoteGitLab")
fileprivate let apiPath = "/api/v4"

public struct RemoteGitLab {
    private let scheme: String
    private let host: String

    public init(scheme: String = "https", host: String) {
        self.scheme = scheme
        self.host = host
    }
    
    private func query<T>(_ type: T.Type, from endpointPath: String, then: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        do {
            log.info("Querying \(endpointPath) from GitLab \(host)")
            let headers = storedNetApiKeys?.gitlab.map { ["Private-Token": $0] } ?? [:]
            let request = try HTTPRequest(scheme: scheme, host: host, path: apiPath + endpointPath, headers: headers)
            return request.fetchJSONAsync(as: type, then: then)
        } catch {
            then(.failure(error))
        }
    }
    
    public func queryPipelines(projectId: Int, then: @escaping (Result<[GitLabPipeline], Error>) -> Void) {
        query([GitLabPipeline].self, from: "/projects/\(projectId)/pipelines", then: then)
    }
    
    public func queryPipeline(projectId: Int, pipelineId: Int, then: @escaping (Result<GitLabPipeline, Error>) -> Void) {
        query(GitLabPipeline.self, from: "/projects/\(projectId)/pipelines/\(pipelineId)", then: then)
    }
    
    public func queryPipelineJobs(projectId: Int, pipelineId: Int, then: @escaping (Result<[GitLabJob], Error>) -> Void) {
        query([GitLabJob].self, from: "/projects/\(projectId)/pipelines/\(pipelineId)/jobs", then: then)
    }
    
    public func queryJobs(projectId: Int, then: @escaping (Result<[GitLabJob], Error>) -> Void) {
        query([GitLabJob].self, from: "/projects/\(projectId)/jobs", then: then)
    }
}
