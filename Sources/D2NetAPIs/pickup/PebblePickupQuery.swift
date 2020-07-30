import D2Utils

public struct PebblePickupQuery: PickupLineQuery {
    public init() {}

    public func perform() -> Promise<PickupLine, Error> {
        Promise.catchingThen {
            let request = try HTTPRequest(host: "pebble-pickup.herokuapp.com", path: "/tweets/random")
            return request.fetchJSONAsync(as: PickupLine.self)
        }
    }
}
