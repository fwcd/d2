import D2Utils

public struct PebblePickupQuery: PickupLineQuery {
    public init() {}

    public func perform() -> Promise<PickupLine, Error> {
        do {
            let request = try HTTPRequest(host: "pebble-pickup.herokuapp.com", path: "/tweets/random")
            request.fetchJSONAsync(as: PickupLine.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
