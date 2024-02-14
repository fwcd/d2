import D2NetAPIs
import D2MessageIO
import Utils

public class WeatherCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the weather for a city",
        presented: true,
        requiredPermissionLevel: .basic
    )

    @Binding private var config: CityConfiguration

    public init(@Binding config: CityConfiguration) {
        self._config = _config
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let city = input.nilIfEmpty ?? config.city else {
            output.append(errorText: "Please enter a city name (or configure a city)!")
            return
        }

        OpenWeatherMapQuery(city: city).perform().listen {
            do {
                let weather = try $0.get()
                output.append(Embed(
                    title: "\(weather.emoji ?? ":question:") The weather for \(weather.name ?? input)",
                    description: weather.weather?.map { "\($0.description) (\($0.main))" }.joined(separator: ", ").nilIfEmpty,
                    footer: weather.coord.map { Embed.Footer(text: "Latitude: \($0.lat) - longitude: \($0.lon)") },
                    fields: [
                        weather.main.map { Embed.Field(name: ":thermometer: Main", value: """
                            **Temperature:** \($0.temp.map { "\($0)" } ?? "?")°C\($0.feelsLike.map { " (feels like \($0)°C)" } ?? "")
                            **Temperature min:** \($0.tempMin.map { "\($0)" } ?? "?")°C
                            **Temperature max:** \($0.tempMax.map { "\($0)" } ?? "?")°C
                            **Pressure:** \($0.pressure.map { "\($0)" } ?? "?") hPa
                            **Humidity:** \($0.humidity.map { "\($0)" } ?? "?")%
                            """) },
                        weather.wind.map { Embed.Field(name: ":wind_blowing_face: Wind", value: """
                            **Speed:** \($0.speed.map { "\($0)" } ?? "?") m/s
                            **Direction:** \($0.deg.map { "\($0)" } ?? "?")°
                            """) },
                        weather.clouds.map { Embed.Field(name: ":cloud: Clouds", value: """
                            **Cloudiness:** \($0.all.map { "\($0)" } ?? "?")%
                            """) },
                        weather.rain.map { Embed.Field(name: ":droplet: Rain", value: """
                            **Last hour:** \($0.lastHour.map { "\($0)" } ?? "?") mm
                            **Last 3 hours:** \($0.last3Hours.map { "\($0)" } ?? "?") mm
                            """) },
                        weather.snow.map { Embed.Field(name: ":snowflake: Snow", value: """
                            **Last hour:** \($0.lastHour.map { "\($0)" } ?? "?") mm
                            **Last 3 hours:** \($0.last3Hours.map { "\($0)" } ?? "?") mm
                            """) },
                        weather.timezone.map { Embed.Field(name: ":earth_africa: Timezone", value: "UTC+\($0)") }
                    ].compactMap { $0 }
                ))
            } catch {
                output.append(error, errorText: "Could not fetch the weather")
            }
        }
    }
}
