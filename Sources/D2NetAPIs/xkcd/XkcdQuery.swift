import D2Utils

public struct XkcdQuery {
    public init() {}

    public func fetch(comicId: Int? = nil, then: @escaping (Result<XkcdComic, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "xkcd.com", path: "\(comicId.map { "/\($0)" } ?? "")/info.0.json")
            request.fetchJSONAsync(as: XkcdComic.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
    
    public func fetchRandom(then: @escaping (Result<XkcdComic, Error>) -> Void) {
        fetch {
            switch $0 {
                case .success(let newest):
                    self.fetch(comicId: Int.random(in: 0..<newest.num), then: then)
                case .failure(let error):
                    then(.failure(error))
            }
        }
    }
}
