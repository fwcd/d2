import Logging
import D2MessageIO
import D2Permissions
import D2NetAPIs

fileprivate let log = Logger(label: "MensaCommand")

/** Fetches the CAU canteen's daily menu. */
public class MensaCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Fetches the CAU canteen's daily menu",
        longDescription: "Looks up the current menu for a CAU canteen",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let canteen = Canteen.parse(from: input) else {
            output.append(errorText: "Could not parse mensa from \(input), try `i` or `ii`")
            return
        }
        
        do {
            try DailyFoodMenu(canteen: canteen).fetchMealsAsync {
                guard case let .success(meals) = $0 else {
                    guard case let .failure(error) = $0 else { fatalError("Result should either be successful or not") }
                    output.append(error, errorText: "An error occurred while performing the request")
                    return
                }
                
                output.append(.embed(Embed(
                    title: ":fork_knife_plate: Today's menu for \(canteen)",
                    fields: meals.map { Embed.Field(name: $0.title, value: "\($0.price) \($0.properties.compactMap(self.emojiOf).joined(separator: " "))") }
                )))
            }
        } catch {
            output.append(error, errorText: "An error occurred while constructing the request")
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
