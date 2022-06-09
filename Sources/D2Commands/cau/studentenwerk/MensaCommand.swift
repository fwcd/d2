import Logging
import D2MessageIO
import Utils
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.MensaCommand")

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
        guard let canteen = Canteen.parse(from: input) else {
            output.append(errorText: "Could not parse mensa from \(input), try `i` or `ii`")
            return
        }

        Promise.catching { try FoodMenuQuery(canteen: canteen) }
            .then { $0.fetchMenusAsync() }
            .listen {
                do {
                    let menus = try $0.get()
                    output.append(Embed(
                        title: ":fork_knife_plate: Today's menu for \(canteen)",
                        fields: menus
                            .sorted(by: ascendingComparator(comparing: \.key))
                            .compactMap { (subcanteen, menu) in
                                guard !menu.isEmpty else { return nil }
                                return Embed.Field(
                                    name: "**+++ \(subcanteen.nilIfEmpty ?? "_No title_") +++**",
                                    value: self.format(menu: menu)
                                )
                            }
                    ))
                } catch {
                    output.append(error, errorText: "An error occurred while constructing the request")
                }
            }
    }

    private func format(menu: FoodMenu) -> String {
        menu.flatMap { meal in
            [
                "**\(meal.title.nilIfEmpty ?? "_no title_")**",
                ("\(meal.price) \(meal.properties.compactMap(self.emojiOf).joined(separator: " "))")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .nilIfEmpty
                    ?? "_no properties_"
            ]
        }.joined(separator: "\n")
    }

    private func emojiOf(mealProperty: MealProperty) -> String? {
        switch mealProperty {
            case .beef: return ":cow2:"
            case .pork: return ":pig:"
            case .chicken: return ":chicken:"
            case .vegetarian: return ":corn:"
            case .vegan: return ":sunflower:"
        }
    }
}
