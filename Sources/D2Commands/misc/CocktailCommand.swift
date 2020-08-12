import D2MessageIO
import D2NetAPIs

public class CocktailCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Searches for a cocktail recipe",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        CocktailDBSearchQuery(term: input).perform().listen {
            do {
                let results = try $0.get()
                guard let drink = results.drinks?.first else {
                    output.append(errorText: "No such drink found!")
                    return
                }
                output.append(Embed(
                    title: ":cocktail: \(drink.strDrink ?? "Cocktail")",
                    footer: (drink.tags.nilIfEmpty?.joined(separator: ", ")).map(Embed.Footer.init(text:)),
                    fields: [
                        Embed.Field(name: "Ingredients", value: drink.ingredients.joined(separator: "\n").nilIfEmpty ?? "_none_")
                    ]
                ))
            } catch {
                output.append(error, errorText: "Could not fetch cocktail")
            }
        }
    }
}
