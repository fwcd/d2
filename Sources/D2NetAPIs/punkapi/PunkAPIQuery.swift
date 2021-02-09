import Utils

public struct PunkAPIQuery {
    private let id: String

    public init(id: String = "random") {
        self.id = id
    }

    public func perform() -> Promise<PunkAPIBeer, Error> {
        Promise.catching { try HTTPRequest(host: "api.punkapi.com", path: "/v2/beers/\(id)") }
            .then { $0.fetchJSONAsync(as: PunkAPIBeer.self) }
    }
}
