import Utils

public struct PunkAPIQuery: Sendable {
    public init() {}

    public func perform() async throws -> [PunkAPIBeer] {
        let request = try HTTPRequest(host: "api.punkapi.com", path: "/v2/beers")
        return try await request.fetchJSON(as: [PunkAPIBeer].self)
    }
}
