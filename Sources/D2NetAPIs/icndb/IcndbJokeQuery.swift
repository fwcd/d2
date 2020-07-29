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

    public func perform() -> Promise<IcndbResult, Error> {
        Promise.catchingThen {
            let request = try HTTPRequest(host: "api.icndb.com", path: "/jokes/random", query: params)
            return request.fetchJSONAsync(as: IcndbResult.self)
        }
    }
}
