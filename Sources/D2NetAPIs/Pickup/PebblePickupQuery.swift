import Utils

public struct PebblePickupQuery: PickupLineQuery {
    public init() {}

    public func perform() async throws -> PickupLine {
        let request = try HTTPRequest(host: "pebble-pickup.herokuapp.com", path: "/tweets/random")
        return try await request.fetchJSON(as: PickupLine.self)
    }
}
