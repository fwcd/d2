import Foundation
import Utils

public struct DallEMiniQuery: Codable {
    private let prompt: String

    public init(prompt: String) {
        self.prompt = prompt
    }

    public func perform() -> Promise<DallEMiniResponse, Error> {
        Promise.catching { () throws -> HTTPRequest in
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

            return try HTTPRequest(
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
        }
        .then { $0.fetchJSONAsync(as: DallEMiniResponse.self) }
    }
}
