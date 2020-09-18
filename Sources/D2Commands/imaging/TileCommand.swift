import D2Utils
import D2MessageIO
import D2Graphics

fileprivate let argsPattern = try! Regex(from: "(x|y)?\\s*(\\d+)?")

public class TileCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Replicates the image along the x- or y-axis",
        helpText: "Syntax: [x|y]? [number of replicas]?",
        requiredPermissionLevel: .vip
    )
    public let inputValueType: RichValueType = .compound([.text, .image])
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let text = input.asText,
            let parsed = argsPattern.firstGroups(in: text),
            let axis = parsed[1].isEmpty ? .x : Axis(rawValue: parsed[1]),
            let replicas = parsed[2].isEmpty ? 2 : Int(parsed[2]) else {
            output.append(errorText: info.helpText!)
            return
        }

        if let img = input.asImage {
            do {
                let width = img.width
                let height = img.height
                let newWidth: Int
                let newHeight: Int

                switch axis {
                    case .x: (newWidth, newHeight) = (width * replicas, height)
                    case .y: (newWidth, newHeight) = (width, height * replicas)
                }

                let pixels = (0..<height).map { y in (0..<width).map { x in img[y, x] } }
                var tiled = try Image(width: newWidth, height: newHeight)

                for y in 0..<height {
                    for x in 0..<width {
                        for i in 0..<replicas {
                            switch axis {
                                case .x: tiled[y, x + (i * width)] = pixels[y][x]
                                case .y: tiled[y + (i * height), x] = pixels[y][x]
                            }
                        }
                    }
                }

                output.append(.image(tiled))
            } catch {
                output.append(error, errorText: "An error occurred while creating a new image")
            }
        } else {
            output.append(errorText: "Not an image!")
        }
    }
}
