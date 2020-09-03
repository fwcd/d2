import Foundation
import D2Utils
import D2NetAPIs
import D2MessageIO

fileprivate let argPattern = try! Regex(from: "(\\w+)\\s*(.*)")
fileprivate let rawFloatPattern = "-?\\d+(?:\\.\\d+)?"
fileprivate let coordsWithRadiusPattern = try! Regex(from: "(\(rawFloatPattern))[\\s,]+(\(rawFloatPattern))(?:\\s+(\(rawFloatPattern)))?")

public class WebcamCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Displays webcams from all around the world",
        requiredPermissionLevel: .basic
    )
    private var subcommands: [String: (String, CommandOutput) -> Void] = [:]

    public init(maxRadius: Int = 250) {
        subcommands = [
            "near": { /*[unowned self]*/ input, output in
                guard let parsedCoordsWithRadius = coordsWithRadiusPattern.firstGroups(in: input), let lat = Double(parsedCoordsWithRadius[1]), let lon = Double(parsedCoordsWithRadius[2]) else {
                    output.append(errorText: "Please enter a pair of lat/lon coordinates!")
                    return
                }
                guard let radius = (parsedCoordsWithRadius[3].nilIfEmpty ?? "10").flatMap({ Int($0) }) else {
                    output.append(errorText: "Please enter a valid radius!")
                    return
                }
                guard radius < maxRadius else {
                    output.append(errorText: "Please enter a radius < \(maxRadius)!")
                    return
                }
                WindyWebcamNearbyQuery(latitude: lat, longitude: lon, radius: radius).perform().listen {
                    do {
                        guard let webcams = try $0.get().result?.webcams else {
                            output.append(errorText: "Did not find any webcams")
                            return
                        }
                        output.append(Embed(
                            title: ":camera: Webcams in a radius of \(radius) km around \(lat), \(lon)",
                            description: webcams
                                .map { "**\($0.title)**: \($0.status) - id: \($0.id)" }
                                .joined(separator: "\n")
                                .truncate(1800, appending: "...")
                        ))
                    } catch {
                        output.append(error, errorText: "Could not query nearby webcams")
                    }
                }
            },
            "show": { /*[unowned self]*/ input, output in
                guard !input.isEmpty else {
                    output.append(errorText: "Please enter a webcam id (e.g. obtained using `near`)")
                    return
                }
                WindyWebcamDetailQuery(id: input).perform().listen {
                    do {
                        guard let webcam = try $0.get().result?.webcams.first else {
                            output.append(errorText: "Did not find any webcams")
                            return
                        }
                        output.append(Embed(
                            title: ":camera_with_flash: Webcam \(webcam.title)",
                            image: webcam.image.flatMap { URL(string: $0.current.preview) }.map { Embed.Image(url: $0) }
                        ))
                    } catch {
                        output.append(error, errorText: "Could not query webcam details")
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
            - `webcam near 0.000 0.000 25` (latitude, longitude, radius in km)
            - `webcam show 123456` (webcam id)
            """
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
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
