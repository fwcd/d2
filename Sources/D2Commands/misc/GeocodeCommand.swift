import D2MessageIO
import D2NetAPIs

public class GeocodeCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Finds the geographical coordinates of an address",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .geoCoordinates
    private let geocoder = MapQuestGeocoder()

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter an address!")
            return
        }

        geocoder.geocode(location: input).listen {
            do {
                try output.append(.geoCoordinates($0.get()))
            } catch {
                output.append(error, errorText: "Could not geocode address")
            }
        }
    }
}
