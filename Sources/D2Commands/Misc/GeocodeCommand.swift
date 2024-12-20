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
    private let geocoder = NominatimGeocoder()

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter an address!")
            return
        }

        do {
            let coords = try await geocoder.geocode(location: input)
            await output.append(.geoCoordinates(coords))
        } catch {
            await output.append(error, errorText: "Could not geocode address")
        }
    }
}
