import Utils

public struct XkcdQuery {
    public init() {}

    public func fetch(comicId: Int? = nil) -> Promise<XkcdComic, Error> {
        Promise.catching { try HTTPRequest(host: "xkcd.com", path: "\(comicId.map { "/\($0)" } ?? "")/info.0.json") }
            .then { $0.fetchJSONAsync(as: XkcdComic.self) }
    }

    public func fetchRandom() -> Promise<XkcdComic, Error> {
        fetch().then { newest in self.fetch(comicId: Int.random(in: 0..<newest.num)) }
    }
}
