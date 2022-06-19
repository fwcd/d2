import Utils

public class CityCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Configures a city e.g. for fetching weather etc.",
        requiredPermissionLevel: .vip
    )

    @AutoSerializing private var config: CityConfiguration

    public init(config _config: AutoSerializing<CityConfiguration>) {
        self._config = _config
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        if input.isEmpty {
            output.append("The configured city is `\(config.city ?? "nil")`")
        } else {
            // TODO: Add option to reset the city to nil?
            config.city = input
            output.append("Successfully set city to `\(input)`")
        }
    }
}
