import Foundation
import Utils

public struct DallEMiniQuery: Codable {
    private let prompt: String

    public init(prompt: String) {
        self.prompt = prompt
    }

    public func perform() -> Promise<DallEMiniResponse, Error> {
        Promise.catching { () throws -> HTTPRequest in
            let jsonData = try JSONEncoder().encode(self)
            guard let json = String(data: jsonData, encoding: .utf8) else {
                throw EncodeError.couldNotDecode(jsonData)
            }
            return try HTTPRequest(
                host: "bf.dallemini.ai",
                path: "/generate",
                method: "POST",
                body: json
            )
        }
        .then { $0.fetchJSONAsync(as: DallEMiniResponse.self) }
    }
}
