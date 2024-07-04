import Utils

public struct PickupLineGenQuery: PickupLineQuery {
    public init() {}

    public func perform() async throws -> PickupLine {
        let request = try HTTPRequest(scheme: "http", host: "www.pickuplinegen.com", path: "/")
        let document = try await request.fetchHTML()
        guard let content = try document.getElementById("content")?.text() else { throw PickupLineGenError.missingContent(document) }
        return PickupLine(tweet: content)
    }
}
