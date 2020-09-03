import GraphViz
import DOT
import D2Graphics

public class GraphVizCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .imaging,
        requiredPermissionLevel: .basic
    )
    private let layout: LayoutAlgorithm

    public init(layout: LayoutAlgorithm) {
        self.layout = layout
        info.shortDescription = "Renders a graph using GraphViz using the \(layout) algorithm"
        info.longDescription = info.shortDescription
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        do {
            let data = try DOTRenderer(using: layout, to: .png).render(dotEncoded: input)
            try output.append(try Image(fromPng: data))
        } catch {
            output.append(error, errorText: "Could not render graph")
        }
    }
}
