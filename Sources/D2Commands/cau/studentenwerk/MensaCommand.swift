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

        Promise.catching { try DailyFoodMenu(canteen: canteen) }
            .then { $0.fetchMealsAsync() }
            .listen {
                do {
                    let meals = try $0.get()
                    output.append(Embed(
                        title: ":fork_knife_plate: Today's menu for \(canteen)",
                        fields: meals.compactMap { meal in
                            guard let title = meal.title.nilIfEmpty else { return nil }
                            return Embed.Field(
                                name: title.nilIfEmpty ?? "_No title_",
                                value: ("\(meal.price) \(meal.properties.compactMap(self.emojiOf).joined(separator: " "))")
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                    .nilIfEmpty
                                    ?? "_no properties_"
                            ) }
                    ))
                } catch {
                    output.append(error, errorText: "An error occurred while constructing the request")
                }
            }
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
