import Utils

public struct PickupLineApiQuery: PickupLineQuery {
    public init() {}

    public func perform() async throws -> PickupLine {
        let request = try HTTPRequest(host: "rizzapi.vercel.app", path: "/random")
        return try await request.fetchJSON(as: PickupLine.self)
    }
}
