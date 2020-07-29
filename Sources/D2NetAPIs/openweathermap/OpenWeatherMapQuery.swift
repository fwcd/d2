import D2Utils

public struct OpenWeatherMapQuery {
    public let city: String
    public let units: String

    public init(city: String, units: String = "metric") {
        self.city = city
        self.units = units
    }

    public func perform() -> Promise<OpenWeatherMapWeather, Error> {
        Promise.catchingThen {
            guard let token = storedNetApiKeys?.openweathermap else {
                throw NetApiError.missingApiKey("Missing OpenWeatherMap API key")
            }
            let request = try HTTPRequest(host: "api.openweathermap.org", path: "/data/2.5/weather", query: ["q": city, "appid": token, "units": units])
            return request.fetchJSONAsync(as: OpenWeatherMapWeather.self)
        }
    }
}
