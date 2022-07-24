import Foundation
import Utils

fileprivate let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd.MM.yyyy"
    return f
}()

public struct NasaAstronomyPictureOfTheDayQuery {
    private let date: Date?

    public init(date: Date? = nil) {
        self.date = date
    }

    public func perform() -> Promise<NasaAstronomyPictureOfTheDay, any Error> {
        Promise.catching {
            try HTTPRequest(
                host: "api.nasa.gov",
                path: "/planetary/apod",
                query: [
                    "date": date.map(dateFormatter.string(from:)),
                    "api_key": storedNetApiKeys?.nasa ?? "DEMO_KEY",
                ].compactMapValues { $0 }
            )
        }
        .then { $0.fetchJSONAsync(as: NasaAstronomyPictureOfTheDay.self) }
    }
}
