import Logging
import Mensa
import D2MessageIO
import Utils
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.MensaCommand")

fileprivate let cauMensaIds = [
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
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let canteenId = cauMensaIds[input.lowercased()] else {
            output.append(errorText: "Unknown mensa `\(input)`, try one of these: \(cauMensaIds.keys.joined(separator: ", "))")
            return
        }

        let client = MensaClient(eventLoopGroup: context.utilityEventLoopGroup)

        Task {
            do {
                let canteen = try await client.canteen(for: canteenId)
                let meals = try await client.meals(for: canteenId)
                let mealsByCategory = [String?: [Meal]](grouping: meals, by: \.category)
                    .map { (key: $0.key ?? "No title", value: $0.value) }
                    .sorted(by: ascendingComparator(comparing: \.key))
                output.append(Embed(
                    title: ":fork_knife_plate: Today's menu for \(canteen.name)",
                    fields: mealsByCategory.compactMap { (category, meals) -> Embed.Field? in
                        guard !meals.isEmpty else { return nil }
                        return Embed.Field(
                            name: "**+++ \(category) +++**",
                            value: self.format(meals: meals.sorted(by: ascendingComparator(comparing: \.name)))
                        )
                    }
                ))
            } catch {
                output.append(error, errorText: "An error occurred while requesting the menu")
            }
        }
    }

    private func format(meals: [Meal]) -> String {
        meals.flatMap { meal in
            [
                "**\(meal.name.nilIfEmpty ?? "_no title_")**",
                ("\(meal.prices) \(meal.notes.compactMap(emojiOf(mealNote:)).joined(separator: " "))")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .nilIfEmpty
                    ?? "_no properties_"
            ]
        }.joined(separator: "\n")
    }

    private func emojiOf(mealNote: String) -> String? {
        switch mealNote.lowercased() {
            case "erdnüsse": return ":peanuts:"
            case "vegetarisch": return ":corn:"
            case "vegan": return ":sunflower:"
            case "milch und laktose": return ":milk:"
            case "rind": return ":cow2:"
            case "schwein aus artgerechter haltung": return ":pig:"
            case "eier": return ":egg:"
            case "geflügel": return ":chicken:"
            default: return nil
        }
    }
}
