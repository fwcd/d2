import Foundation
import Utils

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct DallEMiniQuery: Sendable, Codable {
    private let prompt: String

    public init(prompt: String) {
        self.prompt = prompt
    }

    public func perform() async throws -> DallEMiniResponse {
        // Encode query as JSON
        let jsonData = try JSONEncoder().encode(self)
        guard let json = String(data: jsonData, encoding: .utf8) else {
            throw EncodeError.couldNotDecode(jsonData)
        }

        // We need a custom URL session with longer timeouts
        // since long response times are to be expected
        let configuration = URLSessionConfiguration.default
        let timeout = TimeInterval(200)
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration)

        let request = try HTTPRequest(
            host: "bf.dallemini.ai",
            path: "/generate",
            method: "POST",
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json",
            ],
            body: json,
            session: session
        )
        return try await request.fetchJSON(as: DallEMiniResponse.self)
    }
}
