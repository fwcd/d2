import Foundation
import D2MessageIO
import D2NetAPIs
import Utils

public class RecipeCommand: StringCommand {
    public let info = CommandInfo(
        category: .food,
        shortDescription: "Searches for a food recipe",
        helpText: "Syntax: [search term]",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    private enum RecipeError: Error {
        case noResults
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter something to search for!")
            return
        }

        ChefkochSearchQuery(query: input, limit: 1)
            .perform()
            .thenCatching {
                guard let recipe = $0.first else { throw RecipeError.noResults }
                return ChefkochRecipeQuery(id: recipe.id).perform()
            }
            .listen {
                do {
                    let recipe = try $0.get()
                    output.append(Embed(
                        title: ":taco: \(recipe.title)",
                        url: recipe.siteUrl,
                        thumbnail: URL(string: recipe.thumbnail).map(Embed.Thumbnail.init),
                        fields: [
                            Embed.Field(name: "Ingredients", value: recipe.ingredientList.joined(separator: "\n").nilIfEmpty ?? "_none_")
                        ]
                    ))
                } catch {
                    output.append(error, errorText: "Could not find/fetch recipe")
                }
            }
    }
}
