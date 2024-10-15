public struct SunriseSunsetResults: Sendable, Codable {
    public let status: String
    public let results: Results

    public struct Results: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case sunrise
            case sunset
            case solarNoon = "solar_noon"
            case dayLength = "day_length"
            case civilTwilightBegin = "civil_twilight_begin"
            case civilTwilightEnd = "civil_twilight_end"
            case nauticalTwilightBegin = "nautical_twilight_begin"
            case nauticalTwilightEnd = "nautical_twilight_end"
            case astronomicalTwilightBegin = "astronomical_twilight_begin"
            case astronomicalTwilightEnd = "astronomical_twilight_end"
        }

        // TODO: Parse to Foundation's Date (the format is "hh:mm:ss AM/PM")

        public let sunrise: String?
        public let sunset: String?
        public let solarNoon: String?
        public let dayLength: String?
        public let civilTwilightBegin: String?
        public let civilTwilightEnd: String?
        public let nauticalTwilightBegin: String?
        public let nauticalTwilightEnd: String?
        public let astronomicalTwilightBegin: String?
        public let astronomicalTwilightEnd: String?
    }
}
