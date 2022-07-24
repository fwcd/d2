import Foundation
import Utils

fileprivate let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd.MM.yyyy"
    return f
}()

/// A picture-of-the-day query.
public struct NasaApodQuery {
    private let date: Date?

    public init(date: Date? = nil) {
        self.date = date
    }

    public func perform() -> Promise<NasaApod, any Error> {
        Promise.catching { () -> HTTPRequest in
            guard let apiKey = storedNetApiKeys?.nasa else { throw NetApiError.missingApiKey("No NASA API key found") }
            return try HTTPRequest(
                host: "api.nasa.gov",
                path: "/planetary/apod",
                query: [
                    "date": date.map(dateFormatter.string(from:)),
                    "api_key": apiKey,
                ].compactMapValues { $0 }
            )
        }
        .then { $0.fetchJSONAsync(as: NasaApod.self) }
    }
}
