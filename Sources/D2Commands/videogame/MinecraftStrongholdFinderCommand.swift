import D2MessageIO
import Utils

fileprivate let rawFloatPattern = "(?:-?\\d+(?:\\.\\d+)?)"
fileprivate let rawPointPattern = "(?:\\(\\s*(\(rawFloatPattern))\\s*,\\s*(\(rawFloatPattern))\\s*\\))"
fileprivate let argsPattern = try! Regex(from: "\(rawPointPattern)\\s+\(rawPointPattern)\\s+\(rawPointPattern)\\s+\(rawPointPattern)")

public class MinecraftStrongholdFinderCommand: StringCommand {
    public let info = CommandInfo(
        category: .videogame,
        shortDescription: "Locates the next stronghold on a Minecraft map",
        longDescription: "Locates the next stronghold on a Minecraft map by intersecting the lines traced by successive ender eye throws",
        helpText: """
            Syntax: (from x, from z) (to x, to z) (from x, from z) (to x, to z)

            The first two coordinates trace the line of the first ender eye throw
            and the second two coordinates the line of the second ender eye throw.
            To find the position of the stronghold, this command outputs the
            intersection point (x, z) of both lines.

            e.g. (1, 2) (3, 4) (9, 6) (8, 3)
            """,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }
        let intersect = intersection(
            from1: Vec2(x: Double(parsedArgs[1])!, y: Double(parsedArgs[2])!),
            to1: Vec2(x: Double(parsedArgs[3])!, y: Double(parsedArgs[4])!),
            from2: Vec2(x: Double(parsedArgs[5])!, y: Double(parsedArgs[6])!),
            to2: Vec2(x: Double(parsedArgs[7])!, y: Double(parsedArgs[8])!)
        )
        output.append("The stronghold is located at \(String(format: "(%.2f, %.2f)", intersect.x, intersect.y))")
    }

    /// Computes the intersection point of two 2D-lines.
    private func intersection(from1: Vec2<Double>, to1: Vec2<Double>, from2: Vec2<Double>, to2: Vec2<Double>) -> Vec2<Double> {
        let dir1 = to1 - from1
        let dir2 = to2 - from2
        let t = (from2 - from1).cross(dir2) / dir1.cross(dir2)
        return from1 + (dir1 * t)
    }
}
