import Foundation
import D2MessageIO
import Utils
import D2NetAPIs

fileprivate let argsPattern = #/(?<host>\S+)(?:\s+(?<playerName>.+))?/#

public class MinecraftDynmapCommand: StringCommand {
    public let info = CommandInfo(
        category: .videogame,
        shortDescription: "Queries the dynmap of a Minecraft server",
        longDescription: "Fetches world information from a Minecraft server running the 'dynmap' plugin",
        helpText: "Syntax: [server host] [player name]?",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let parsedArgs = try? argsPattern.firstMatch(in: input) else {
            await output.append(errorText: info.helpText!)
            return
        }
        let host = String(parsedArgs.host)
        let playerName = parsedArgs.playerName.map { String($0) }
        do {
            let config = try await MinecraftDynmapConfigurationQuery(host: host).perform()
            let worldName = config.defaultworld ?? "world"
            do {
                let world = try await MinecraftDynmapWorldQuery(host: host, world: worldName).perform()
                if let name = playerName, let map = config.worlds?.first(where: { $0.name == worldName })?.maps?.first {
                    if let player = world.players?.first(where: { $0.name == name }) {
                        await output.append(Embed(
                            title: "Minecraft Player `\(name)`",
                            description: self.describe(player: player),
                            image: URL(string: "http://\(host):8123/\(self.tilePath(for: player, on: map))").map { Embed.Image(url: $0) }
                        ))
                    } else {
                        await output.append(errorText: "Could not find player `\(name)` on server")
                    }
                } else {
                    await output.append(Embed(
                        title: "Minecraft Server Dynmap",
                        fields: world.players?.map { Embed.Field(name: $0.name ?? "Unnamed player", value: self.describe(player: $0)) } ?? []
                    ))
                }
            } catch {
                await output.append(error, errorText: "World query failed")
            }
        } catch {
            await output.append(error, errorText: "Configuration query failed")
        }
    }

    private func formatBars(bar: String, halfBar: String, value: Int) -> String {
        String(repeating: bar, count: value / 2) + String(repeating: halfBar, count: value % 2)
    }

    private func describe(player: MinecraftDynmapWorld.Player) -> String {
        """
        :earth_africa: \(player.world ?? "world")
        :compass: x: \(player.x ?? 0), y: \(player.y ?? 0), z: \(player.z ?? 0)
        \(formatBars(bar: ":heart:", halfBar: ":broken_heart:", value: Int(player.health ?? 0)))
        \(formatBars(bar: ":shirt:", halfBar: ":running_shirt_with_sash:", value: player.armor ?? 0))
        """
    }

    private func tilePath(for player: MinecraftDynmapWorld.Player, on map: MinecraftDynmapConfiguration.World.Map, zoomLevel: Int = 2) -> String {
        let zoomPrefix = String(repeating: "z", count: zoomLevel) + (zoomLevel > 0 ? "_" : "")
        let (rawTileX, rawTileY) = map.toTilePos(x: player.x ?? 0, y: player.y ?? 0, z: player.z ?? 0)
        let rounding = 1 << zoomLevel
        let tileX = (Int(rawTileX) / rounding) * rounding
        let tileY = (Int(rawTileY) / rounding) * rounding
        let gridSize = 32
        let gridX = tileX / gridSize
        let gridY = tileY / gridSize
        return "tiles/\(player.world ?? "world")/\(map.name ?? "flat")/\(gridX)_\(gridY)/\(zoomPrefix)\(tileX)_\(tileY).png"
    }
}
