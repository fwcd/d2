@preconcurrency import GraphViz
@preconcurrency import CairoGraphics

public class GraphVizCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .imaging,
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let layout: LayoutAlgorithm

    public init(layout: LayoutAlgorithm) {
        self.layout = layout
        info.shortDescription = "Renders a graph using GraphViz using the \(layout) algorithm"
        info.longDescription = info.shortDescription
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let data = try await withCheckedThrowingContinuation { continuation in
                Renderer(layout: layout).render(dot: input, to: .png) {
                    continuation.resume(with: $0)
                }
            }
            try await output.append(try CairoImage(pngData: data))
        } catch {
            await output.append(error, errorText: "Could not render graph")
        }
    }
}
