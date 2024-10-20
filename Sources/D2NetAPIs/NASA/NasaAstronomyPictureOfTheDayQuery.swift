import Foundation
import Utils

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd.MM.yyyy"
    return f
}()

public struct NasaAstronomyPictureOfTheDayQuery: Sendable {
    private let date: Date?

    public init(date: Date? = nil) {
        self.date = date
    }

    public func perform() async throws -> NasaAstronomyPictureOfTheDay {
        let request = try HTTPRequest(
            host: "api.nasa.gov",
            path: "/planetary/apod",
            query: [
                "date": date.map(dateFormatter.string(from:)),
                "api_key": storedNetApiKeys?.nasa ?? "DEMO_KEY",
            ].compactMapValues { $0 }
        )
        return try await request.fetchJSON(as: NasaAstronomyPictureOfTheDay.self)
    }
}
