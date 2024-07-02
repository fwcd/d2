import D2MessageIO
import D2NetAPIs

public class GeocodeCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Finds the geographical coordinates of an address",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .geoCoordinates
    private let geocoder = MapQuestGeocoder()

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter an address!")
            return
        }

        do {
            let coords = try await geocoder.geocode(location: input)
            output.append(.geoCoordinates(coords))
        } catch {
            output.append(error, errorText: "Could not geocode address")
        }
    }
}
