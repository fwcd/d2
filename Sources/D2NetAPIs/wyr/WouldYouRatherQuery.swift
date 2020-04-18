import D2Utils

public struct WouldYouRatherQuery {
    public init() {}
    
    public func perform(then: @escaping (Result<WouldYouRather, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "www.rrrather.com", path: "/botapi")
            request.fetchJSONAsync(as: WouldYouRather.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
