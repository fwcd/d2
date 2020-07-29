import D2Utils

public struct FTBModpacksQuery {
    public init() {}

    public func perform() -> Promise<[FTBModpack], Error> {
        do {
            let request = try HTTPRequest(host: "ftb.forgecdn.net", path: "/FTB2/static/modpacks.xml")
            request.fetchXMLAsync(using: FTBModpacksXMLParserDelegate(then: then), then: then)
        } catch {
            then(.failure(error))
        }
    }
}
