import D2MessageIO
import D2NetAPIs

public class OpenFoodFactsCommand: StringCommand {
    public let info = CommandInfo(
        category: .food,
        shortDescription: "Queries the OpenFoodFacts database",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter the EAN (barcode number) of some product!")
            return
        }

        OpenFoodFactsQuery(code: input).perform().listen {
            do {
                let product = try $0.get().product
                output.append(Embed(
                    title: product.genericNameEn ?? product.productNameEnImported,
                    thumbnail: product.imageThumbUrl.map(Embed.Thumbnail.init(url:)),
                    footer: product.creator?.nilIfEmpty.map { Embed.Footer(text: "creator: \($0)") },
                    fields: [
                        Embed.Field(name: "Ingredients", value: (product.ingredientsTextWithAllergensEn ?? product.ingredientsTextEn)?.nilIfEmpty ?? "_none_")
                    ]
                ))
            } catch {
                output.append(error, errorText: "Could not query OpenFoodFacts database")
            }
        }
    }
}
