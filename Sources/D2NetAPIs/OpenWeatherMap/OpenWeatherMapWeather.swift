public struct OpenWeatherMapWeather: Sendable, Codable {
    public let coord: Coord?
    public let weather: [Weather]?
    public let base: String?
    public let main: Main?
    public let visibility: Int?
    public let wind: Wind?
    public let clouds: Clouds?
    public let rain: Precipitation?
    public let snow: Precipitation?
    public let dt: Int?
    public let sys: Sys?
    public let timezone: Int?
    public let id: Int?
    public let name: String?
    public let cod: Int?

    public var emoji: String? {
        weather?.compactMap(\.emoji).first
    }

    public struct Coord: Sendable, Codable {
        public let lon: Double
        public let lat: Double
    }

    public struct Weather: Sendable, Codable {
        public let id: Int
        public let main: String
        public let description: String
        public let icon: String

        public var emoji: String? {
            Self.emojiFor(main: main, description: description)
        }

        public static func emojiFor(main: String, description: String) -> String? {
            switch main.lowercased() {
            case "clear":
                return "☀️"
            case "clouds":
                return description.contains("few")
                    ? "🌤"
                    : description.contains("scattered")
                    ? "⛅"
                    : description.contains("broken")
                    ? "🌥"
                    : "☁️"
            case "thunderstorm":
                return description.contains("rain") || description.contains("drizzle")
                    ? "⛈"
                    : "🌩"
            case "drizzle":
                return "🌦"
            case "rain":
                return "🌧"
            case "snow":
                return "❄️"
            case "extreme", "tornado":
                return "🌪"
            case "mist", "smoke", "haze", "dust", "fog", "sand", "ash", "squall":
                return "🌫"
            default:
                return nil
            }
        }
    }

    public struct Main: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case pressure
            case humidity
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }

        public let temp: Double?
        public let feelsLike: Double?
        public let pressure: Double?
        public let humidity: Double?
        public let tempMin: Double?
        public let tempMax: Double?
    }

    public struct Wind: Sendable, Codable {
        public let speed: Double?
        public let deg: Double?
        public let gust: Double?
    }

    public struct Clouds: Sendable, Codable {
        public let all: Int?
    }

    public struct Sys: Sendable, Codable {
        public let type: Int?
        public let id: Int?
        public let message: Double?
        public let country: String?
        public let sunrise: Int?
        public let sunset: Int?
    }

    public struct Precipitation: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case lastHour = "1h"
            case last3Hours = "3h"
        }

        public let lastHour: Double?
        public let last3Hours: Double?
    }
}
