import D2Utils
import D2NetAPIs
import D2MessageIO

fileprivate let argPattern = try! Regex(from: "(\\w+)\\s*(.*)")
fileprivate let rawFloatPattern = "\\d+(?:\\.\\d+)?"
fileprivate let coordsPattern = try! Regex(from: "(\(rawFloatPattern))[\\s,]+(\(rawFloatPattern))")

public class WebcamCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Displays webcams from all around the world",
        requiredPermissionLevel: .basic
    )
    private var subcommands: [String: (String, CommandOutput) -> Void] = [:]

    public init() {
        subcommands = [
            "near": { [unowned self] input, output in
                guard let parsedCoords = coordsPattern.firstGroups(in: input), let lat = Double(parsedCoords[1]), let lon = Double(parsedCoords[2]) else {
                    output.append(errorText: "Please enter a pair of lat/lon coordinates!")
                    return
                }
                WindyWebcamNearbyQuery(latitude: lat, longitude: lon, radius: 10).perform {
                    do {
                        guard let webcams = try $0.get().result?.webcams else {
                            output.append(errorText: "Did not find any webcams")
                            return
                        }
                        output.append(Embed(
                            title: ":camera: Nearby Webcams",
                            description: webcams
                                .map { "**\($0.title)**: \($0.status) - id: \($0.id)" }
                                .joined(separator: "\n")
                                .truncate(1800, appending: "...")
                        ))
                    } catch {
                        output.append(error, errorText: "Could not query nearby webcams")
                    }
                }
            }
        ]
        info.helpText = """
            Syntax: `[subcommand] [args]`

            Available subcommands:
            \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))

            Examples:
            - `webcam near 0.000 0.000` (latitude, longitude)
            - `webcam show 123456` (webcam id)
            """
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }

        guard let subcommand = subcommands[parsedArgs[1]] else {
            output.append(errorText: "Could not find subcommand `\(parsedArgs[1])`. Try one of these: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }

        subcommand(parsedArgs[2], output)
    }
}
