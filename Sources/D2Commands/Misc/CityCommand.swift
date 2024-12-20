import Utils

public class CityCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Configures a city e.g. for fetching weather etc.",
        requiredPermissionLevel: .vip
    )

    @Binding private var config: CityConfiguration

    public init(@Binding config: CityConfiguration) {
        self._config = _config
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) async {
        if input.isEmpty {
            await output.append("The configured city is `\(config.city ?? "nil")`")
        } else {
            // TODO: Add option to reset the city to nil?
            config.city = input
            await output.append("Successfully set city to `\(input)`")
        }
    }
}
