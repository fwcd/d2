import Foundation
import D2MessageIO
import D2NetAPIs
import Utils

public class CocktailCommand: StringCommand {
    public let info = CommandInfo(
        category: .food,
        shortDescription: "Searches for a cocktail recipe",
        helpText: "Syntax: [search term]",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let results = try await CocktailDBSearchQuery(term: input).perform()
            guard let drink = results.drinks?.first else {
                await output.append(errorText: "No such drink found!")
                return
            }
            await output.append(Embed(
                title: ":cocktail: \(drink.strDrink ?? "Cocktail")",
                thumbnail: drink.strDrinkThumb.flatMap(URL.init(string:)).map(Embed.Thumbnail.init),
                footer: (drink.tags.nilIfEmpty?.joined(separator: ", ")).map(Embed.Footer.init(text:)),
                fields: [
                    Embed.Field(name: "Ingredients", value: drink.measuredIngredients.map { [$0.0, $0.1].compactMap { $0 }.joined(separator: " ") }.joined(separator: "\n").nilIfEmpty ?? "_none_", inline: true),
                    Embed.Field(name: "Category", value: [drink.strCategory, drink.strIBA, drink.strAlcoholic].compactMap { $0 }.nilIfEmpty?.joined(separator: "\n") ?? "_none_", inline: true),
                    Embed.Field(name: "Glass", value: drink.strGlass ?? "_none_", inline: true),
                    Embed.Field(name: "Instructions", value: drink.strInstructions ?? "_none_")
                ]
            ))
        } catch {
            await output.append(error, errorText: "Could not fetch cocktail")
        }
    }
}
