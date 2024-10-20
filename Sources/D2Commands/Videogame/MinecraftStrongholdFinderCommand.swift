import D2MessageIO
import RegexBuilder
import Utils

nonisolated(unsafe) private let rawFloatPattern = #/(?:-?\d+(?:\.\d+)?)/#
nonisolated(unsafe) private let pointPattern = Regex {
    #/\(\s*/#
    Capture { rawFloatPattern } transform: { Double($0)! }
    #/\s*,\s*/#
    Capture { rawFloatPattern } transform: { Double($0)! }
    #/\s*\)/#
}

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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let parsedPoints = input.matches(of: pointPattern).map { Vec2(x: $0.1, y: $0.2) }
        guard parsedPoints.count == 4 else {
            await output.append(errorText: "Locating a stronghold requires specifying 4 points (forming 2 lines, respectively)")
            return
        }
        let intersect = intersection(from1: parsedPoints[0], to1: parsedPoints[1], from2: parsedPoints[2], to2: parsedPoints[3])
        await output.append("The stronghold is located at \(String(format: "(%.2f, %.2f)", intersect.x, intersect.y))")
    }

    /// Computes the intersection point of two 2D-lines.
    private func intersection(from1: Vec2<Double>, to1: Vec2<Double>, from2: Vec2<Double>, to2: Vec2<Double>) -> Vec2<Double> {
        let dir1 = to1 - from1
        let dir2 = to2 - from2
        let t = (from2 - from1).cross(dir2) / dir1.cross(dir2)
        return from1 + (dir1 * t)
    }
}
