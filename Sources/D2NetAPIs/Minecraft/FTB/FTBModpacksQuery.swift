import Utils

public struct FTBModpacksQuery: Sendable {
    public init() {}

    public func perform() async throws -> [FTBModpack] {
        let request = try HTTPRequest(host: "ftb.forgecdn.net", path: "/FTB2/static/modpacks.xml")
        return try await withCheckedThrowingContinuation { continuation in
            request.fetchXMLAsync {
                FTBModpacksXMLParserDelegate(continuation: continuation)
            }
        }
    }
}
