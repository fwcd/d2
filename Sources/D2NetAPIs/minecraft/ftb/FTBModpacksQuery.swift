import D2Utils

public struct FTBModpacksQuery {
    public init() {}

    public func perform() -> Promise<[FTBModpack], Error> {
        Promise.catching { try HTTPRequest(host: "ftb.forgecdn.net", path: "/FTB2/static/modpacks.xml") }
            .then { req in Promise { then in req.fetchXMLAsync(using: FTBModpacksXMLParserDelegate(then: then)) } }
    }
}
