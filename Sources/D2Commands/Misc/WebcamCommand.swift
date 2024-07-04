import Foundation
import RegexBuilder
import Utils
import D2NetAPIs
import D2MessageIO

fileprivate let argPattern = #/(?<name>\w+)\s*(?<args>.*)/#
fileprivate let rawFloatPattern = #/-?\d+(?:\.\d+)?/#
fileprivate let coordsWithRadiusPattern = Regex {
    Capture { rawFloatPattern }
    #/[\s,]+/#
    Capture { rawFloatPattern }
    Optionally {
        #/\s+/#
        Capture { rawFloatPattern }
    }
}

public class WebcamCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Displays webcams from all around the world",
        requiredPermissionLevel: .basic
    )
    private var subcommands: [String: (String, CommandOutput) async -> Void] = [:]

    public init(maxRadius: Int = 250) {
        subcommands = [
            "near": { /*[unowned self]*/ input, output in
                guard let parsedCoordsWithRadius = try? coordsWithRadiusPattern.firstMatch(in: input), let lat = Double(parsedCoordsWithRadius.1), let lon = Double(parsedCoordsWithRadius.2) else {
                    await output.append(errorText: "Please enter a pair of lat/lon coordinates!")
                    return
                }
                guard let radius = (parsedCoordsWithRadius.3 ?? "10").flatMap({ Int($0) }) else {
                    await output.append(errorText: "Please enter a valid radius!")
                    return
                }
                guard radius < maxRadius else {
                    await output.append(errorText: "Please enter a radius < \(maxRadius)!")
                    return
                }
                do {
                    guard let webcams = try await WindyWebcamNearbyQuery(latitude: lat, longitude: lon, radius: radius).perform().result?.webcams else {
                        await output.append(errorText: "Did not find any webcams")
                        return
                    }
                    await output.append(Embed(
                        title: ":camera: Webcams in a radius of \(radius) km around \(lat), \(lon)",
                        description: webcams
                            .map { "**\($0.title)**: \($0.status) - id: \($0.id)" }
                            .joined(separator: "\n")
                            .truncated(to: 1800, appending: "...")
                    ))
                } catch {
                    await output.append(error, errorText: "Could not query nearby webcams")
                }
            },
            "show": { /*[unowned self]*/ input, output in
                guard !input.isEmpty else {
                    await output.append(errorText: "Please enter a webcam id (e.g. obtained using `near`)")
                    return
                }
                do {
                    guard let webcam = try await WindyWebcamDetailQuery(id: input).perform().result?.webcams.first else {
                        await output.append(errorText: "Did not find any webcams")
                        return
                    }
                    await output.append(Embed(
                        title: ":camera_with_flash: Webcam \(webcam.title)",
                        image: webcam.image.flatMap { URL(string: $0.current.preview) }.map { Embed.Image(url: $0) }
                    ))
                } catch {
                    await output.append(error, errorText: "Could not query webcam details")
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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let parsedArgs = try? argPattern.firstMatch(in: input) else {
            await output.append(errorText: info.helpText!)
            return
        }

        guard let subcommand = subcommands[String(parsedArgs.name)] else {
            await output.append(errorText: "Could not find subcommand `\(parsedArgs.name)`. Try one of these: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))")
            return
        }

        await subcommand(String(parsedArgs.args), output)
    }
}
