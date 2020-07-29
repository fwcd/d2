import D2Utils

public struct PickupLineGenQuery: PickupLineQuery {
    public init() {}

    public func perform() -> Promise<PickupLine, Error> {
        Promise.catching { try HTTPRequest(scheme: "http", host: "www.pickuplinegen.com", path: "/") }
            .then { $0.fetchHTMLAsync() }
            .mapCatching { doc in
                guard let content = try doc.getElementById("content")?.text() else { throw PickupLineGenError.missingContent(doc) }
                return PickupLine(tweet: content)
            }
    }
}
