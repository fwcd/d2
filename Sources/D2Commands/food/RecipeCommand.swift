import Foundation
import D2MessageIO
import D2NetAPIs

public class RecipeCommand: StringCommand {
    public let info = CommandInfo(
        category: .food,
        shortDescription: "Searches for a food recipe",
        helpText: "Syntax: [search term]",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        RecipePuppyQuery(term: input).perform().listen {
            do {
                let response = try $0.get()
                guard let recipe = response.results.first else {
                    output.append(errorText: "No recipe found!")
                    return
                }
                output.append(Embed(
                    title: ":taco: \(recipe.title)",
                    url: URL(string: recipe.href),
                    thumbnail: URL(string: recipe.thumbnail).map(Embed.Thumbnail.init),
                    fields: [
                        Embed.Field(name: "Ingredients", value: recipe.ingredientList.joined(separator: "\n").nilIfEmpty ?? "_none_")
                    ]
                ))
            } catch {
                output.append(error, errorText: "Could not fetch cocktail")
            }
        }
    }
}
