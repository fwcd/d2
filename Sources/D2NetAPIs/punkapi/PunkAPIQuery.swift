import Utils

public struct PunkAPIQuery {
    public init() {}

    public func perform() -> Promise<[PunkAPIBeer], Error> {
        Promise.catching { try HTTPRequest(host: "api.punkapi.com", path: "/v2/beers") }
            .then { $0.fetchJSONAsync(as: [PunkAPIBeer].self) }
    }
}
