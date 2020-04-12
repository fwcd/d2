import D2Utils

public struct IcndbJokeQuery {
    private var params: [String: String] = [:]
    
    public init(
        firstName: String? = nil,
        lastName: String? = nil
    ) {
        params["firstName"] = firstName
        params["lastName"] = lastName
    }
    
    public func perform(then: @escaping (Result<IcndbResult, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "api.icndb.com", path: "/jokes/random", query: params)
            request.fetchJSONAsync(as: IcndbResult.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
