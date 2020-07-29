import D2Utils

public struct PickupLineGenQuery: PickupLineQuery {
    public init() {}

    public func perform() -> Promise<PickupLine, Error> {
        do {
            let request = try HTTPRequest(scheme: "http", host: "www.pickuplinegen.com", path: "/")
            request.fetchHTMLAsync {
                do {
                    let doc = try $0.get()
                    guard let content = try doc.getElementById("content")?.text() else { throw PickupLineGenError.missingContent(doc) }
                    then(.success(PickupLine(tweet: content)))
                } catch {
                    then(.failure(error))
                }
            }
        } catch {
            then(.failure(error))
        }
    }
}
