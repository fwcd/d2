public class CSSSelectorCommand: Command {
    public let info = CommandInfo(
        category: .net,
        shortDescription: "Finds DOM child nodes using a CSS selector",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .domNode
    public let outputValueType: RichValueType = .compound([.domNode])

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        do {
            guard let node = input.asDomNode else {
                await output.append(errorText: "Please provide a DOM node to perform the selector on!")
                return
            }
            guard let selector = input.asText else {
                await output.append(errorText: "Please provide a CSS selector!")
                return
            }
            let selection: [RichValue] = try node.select(selector).array().map { .domNode($0) }
            await output.append(.compound(selection))
        } catch {
            await output.append(error, errorText: "Could not perform CSS selector")
        }
    }
}
