import Utils

public struct OpenWeatherMapQuery: Sendable {
    public let city: String
    public let units: String

    public init(city: String, units: String = "metric") {
        self.city = city
        self.units = units
    }

    public func perform() async throws -> OpenWeatherMapWeather {
        guard let token = storedNetApiKeys?.openweathermap else {
            throw NetApiError.missingApiKey("Missing OpenWeatherMap API key")
        }
        let request = try HTTPRequest(host: "api.openweathermap.org", path: "/data/2.5/weather", query: ["q": city, "appid": token, "units": units])
        return try await request.fetchJSON(as: OpenWeatherMapWeather.self)
    }
}
