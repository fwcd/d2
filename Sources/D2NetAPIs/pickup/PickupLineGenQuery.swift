import D2Utils

public struct PickupLineGenQuery: PickupLineQuery {
    public init() {}

    public func perform() -> Promise<PickupLine, Error> {
        .catchingThen {
            let request = try HTTPRequest(scheme: "http", host: "www.pickuplinegen.com", path: "/")
            return request.fetchHTMLAsync().then { doc in
                .catching {
                    let doc = try $0.get()
                    guard let content = try doc.getElementById("content")?.text() else { throw PickupLineGenError.missingContent(doc) }
                    return PickupLine(tweet: content)
                }
            }
        }
    }
}
