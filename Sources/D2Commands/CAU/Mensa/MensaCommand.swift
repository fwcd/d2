import Logging
import Mensa
import D2MessageIO
import Utils
import D2NetAPIs

private let log = Logger(label: "D2Commands.MensaCommand")

private let cauMensaIds = [
    "1": 1216,
    "2": 1218,
    "schwentine": 1219,
]

/// Fetches the CAU canteen's daily menu.
public class MensaCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Fetches the CAU canteen's daily menu",
        longDescription: "Looks up the current menu for a CAU canteen",
        helpText: "Syntax: [\(cauMensaIds.keys.sorted().joined(separator: " | "))]",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please specify a mensa: \(cauMensaIds.keys.sorted().joined(separator: ", "))")
            return
        }
        guard let canteenId = cauMensaIds[input.lowercased()] else {
            await output.append(errorText: "Unknown mensa `\(input)`, try one of these: \(cauMensaIds.keys.sorted().joined(separator: ", "))")
            return
        }

        let client = MensaClient(eventLoopGroup: context.eventLoopGroup)

        do {
            let canteen = try await client.canteen(for: canteenId)
            do {
                let meals = try await client.meals(for: canteenId)
                await output.append(Embed(
                    title: ":fork_knife_plate: Today's menu for \(canteen.name)",
                    fields: meals.map { meal in
                        Embed.Field(
                            name: "\(meal.name)\(meal.category.map { " [\($0)]" } ?? "")".nilIfEmpty ?? "?",
                            value: format(meal: meal)
                        )
                    }
                ))
            } catch MensaError.notFound {
                await output.append(Embed(
                    title: ":fork_knife_plate: No menu for \(canteen.name) today"
                ))
            }
        } catch {
            await output.append(error, errorText: "An error occurred while requesting the menu")
        }
    }

    private func format(meal: Meal) -> String {
        ("\(meal.prices) \(emojisOf(attributes: meal.attributes))")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty
            ?? "_no properties_"
    }

    private func emojisOf(attributes: Meal.Attributes) -> String {
        var emojis: [String] = []
        if attributes.contains(.vegetarian) { emojis.append(":corn:") }
        if attributes.contains(.vegan) { emojis.append(":sunflower:") }
        if attributes.contains(.lactose) { emojis.append(":milk:") }
        if attributes.contains(.beef) { emojis.append(":cow2:") }
        if attributes.contains(.pork) { emojis.append(":pig:") }
        if attributes.contains(.eggs) { emojis.append(":egg:") }
        if attributes.contains(.poultry) { emojis.append(":chicken:") }
        if attributes.contains(.peanuts) { emojis.append(":peanuts:") }
        if attributes.contains(.fish) { emojis.append(":fish:") }
        return emojis.joined(separator: " ")
    }
}
