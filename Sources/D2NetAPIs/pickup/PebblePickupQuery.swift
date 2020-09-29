import Utils

public struct PebblePickupQuery: PickupLineQuery {
    public init() {}

    public func perform() -> Promise<PickupLine, Error> {
        Promise.catching { try HTTPRequest(host: "pebble-pickup.herokuapp.com", path: "/tweets/random") }
            .then { $0.fetchJSONAsync(as: PickupLine.self) }
    }
}
