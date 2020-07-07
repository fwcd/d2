import D2Utils

public struct PickupLineQuery {
    public init() {}

    public func perform(then: @escaping (Result<PickupLine, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "pebble-pickup.herokuapp.com", path: "/tweets/random")
            request.fetchJSONAsync(as: PickupLine.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
