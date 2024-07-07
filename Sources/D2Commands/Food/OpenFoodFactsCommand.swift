import D2MessageIO
import D2NetAPIs

public class OpenFoodFactsCommand: StringCommand {
    public let info = CommandInfo(
        category: .food,
        shortDescription: "Queries the OpenFoodFacts database",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter the EAN (barcode number) of some product!")
            return
        }

        do {
            let product = try await OpenFoodFactsQuery(code: input).perform().product
            await output.append(Embed(
                title: [product.genericName ?? product.genericNameEn ?? product.genericNameDe, product.productNameEnImported].compactMap { $0 }.joined(separator: ": ").nilIfEmpty ?? "Untitled product",
                thumbnail: product.imageThumbUrl.map(Embed.Thumbnail.init(url:)),
                footer: product.creator?.nilIfEmpty.map { "creator: \($0)" },
                fields: [
                    Embed.Field(name: "Ingredients", value: (product.ingredientsTextWithAllergensEn ?? product.ingredientsTextEn)?.nilIfEmpty ?? "_none_")
                ]
            ))
        } catch {
            await output.append(error, errorText: "Could not query OpenFoodFacts database")
        }
    }
}
