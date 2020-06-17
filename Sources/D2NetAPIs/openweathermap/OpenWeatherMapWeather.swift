public struct OpenWeatherMapWeather: Codable {
    public let coord: Coord?
    public let weather: [Weather]?
    public let base: String?
    public let main: Main?
    public let visibility: Int?
    public let wind: Wind?
    public let clouds: Clouds?
    public let dt: Int?
    public let sys: Sys?
    public let timezone: Int?
    public let id: Int?
    public let name: String?
    public let cod: Int?

    public struct Coord: Codable {
        public let lon: Double
        public let lat: Double
    }

    public struct Weather: Codable {
        public let id: Int
        public let main: String
        public let description: String
        public let icon: String
    }

    public struct Main: Codable {
        public enum CodingKeys: String, CodingKey {
            case temp
            case pressure
            case humidity
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }

        public let temp: Double
        public let pressure: Double
        public let humidity: Double
        public let tempMin: Double
        public let tempMax: Double
    }

    public struct Wind: Codable {
        public let speed: Double
        public let deg: Double
    }

    public struct Clouds: Codable {
        public let all: Int
    }

    public struct Sys: Codable {
        public let type: Int
        public let id: Int
        public let message: Double
        public let country: String
        public let sunrise: Int
        public let sunset: Int
    }
}
