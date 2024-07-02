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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter something to search for!")
            return
        }

        do {
            let searchResults = try await ChefkochSearchQuery(query: input, limit: 1).perform()
            guard let searchRecipe = searchResults.results.first?.recipe else { throw RecipeError.noResults }

            let recipe = try await ChefkochRecipeQuery(id: searchRecipe.id).perform()

            var thumbnailUrl: URL?
            if let imageId = recipe.previewImageId {
                let image = try await ChefkochImageQuery(recipeId: recipe.id, imageId: imageId).perform()
                thumbnailUrl = image.thumbnailUrl
            }

            await output.append(Embed(
                title: ":taco: \(recipe.title)",
                url: recipe.siteUrl.flatMap(URL.init(string:)),
                thumbnail: thumbnailUrl.map(Embed.Thumbnail.init),
                footer: Embed.Footer(text: String(format: "Rating: %.2f stars, %d votes", recipe.rating?.rating ?? 0, recipe.rating?.numVotes ?? 0)),
                fields: [
                    Embed.Field(name: "Ingredients", value: recipe.ingredientGroups.map(self.format(ingredientGroups:))?.nilIfEmpty ?? "_none_", inline: true),
                    Embed.Field(name: "Time", value: [
                        "Cooking": recipe.cookingTime.map(self.format(time:)),
                        "Resting": recipe.restingTime.map(self.format(time:)),
                        "Total": recipe.totalTime.map(self.format(time:)),
                    ].compactMap { (k, v) in v.map { "\(k): \($0)" } }.joined(separator: "\n").nilIfEmpty ?? "_none_", inline: true),
                ] + (recipe.instructions?
                    .truncated(to: 4000, appending: "...")
                    .chunks(ofLength: 800)
                    .filter { !$0.isEmpty }
                    .enumerated()
                    .map { (i, chunk) in Embed.Field(name: "Instructions (part \(i + 1))", value: String(chunk), inline: false) }
                    ?? [])
            ))
        } catch {
            await output.append(error, errorText: "Could not find/fetch recipe")
        }
    }

    private func format(time: Double) -> String {
        String(format: "%.2f min", time)
    }

    private func format(ingredientGroups: [ChefkochRecipe.IngredientGroup]) -> String {
        ingredientGroups
            .flatMap {
                [
                    ($0.header?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty)
                        .map { "**\($0)**" },
                    format(ingredients: $0.ingredients)
                ].compactMap { $0 }
            }
            .joined(separator: "\n")
    }

    private func format(ingredients: [ChefkochRecipe.IngredientGroup.Ingredient]) -> String {
        ingredients
            .map(format(ingredient:))
            .joined(separator: "\n")
    }

    private func format(ingredient: ChefkochRecipe.IngredientGroup.Ingredient) -> String {
        "\(ingredient.amount) \(ingredient.unit) \(ingredient.name)"
    }
}
