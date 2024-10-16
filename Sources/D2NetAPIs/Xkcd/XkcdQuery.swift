import Utils

public struct XkcdQuery: Sendable {
    public init() {}

    public func fetch(comicId: Int? = nil) async throws -> XkcdComic {
        let request = try HTTPRequest(host: "xkcd.com", path: "\(comicId.map { "/\($0)" } ?? "")/info.0.json")
        return try await request.fetchJSON(as: XkcdComic.self)
    }

    public func fetchRandom() async throws -> XkcdComic {
        let newest = try await fetch()
        return try await fetch(comicId: Int.random(in: 0..<newest.num))
    }
}
