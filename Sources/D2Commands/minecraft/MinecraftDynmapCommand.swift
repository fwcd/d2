import Foundation
import D2MessageIO
import D2Utils
import D2NetAPIs

fileprivate let argsPattern = try! Regex(from: "(\\S+)(?:\\s+(.+))?")

public class MinecraftDynmapCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Queries the dynmap of a Minecraft server",
        longDescription: "Fetches world information from a Minecraft server running the 'dynmap' plugin",
        helpText: "Syntax: [server host] [player name]?",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }
        let host = parsedArgs[1]
        let playerName = parsedArgs[2].nilIfEmpty
        MinecraftDynmapConfigurationQuery(host: host).perform {
            switch $0 {
                case .success(let config):
                    let worldName = config.defaultworld ?? "world"
                    MinecraftDynmapWorldQuery(host: host, world: worldName).perform {
                        switch $0 {
                            case .success(let world):
                                if let name = playerName, let map = config.worlds?.first(where: { $0.name == worldName })?.maps?.first {
                                    if let player = world.players?.first(where: { $0.name == name }) {
                                        output.append(Embed(
                                            title: "Minecraft Player `\(name)`",
                                            description: self.describe(player: player),
                                            image: URL(string: "http://\(host):8123/\(self.tilePath(for: player, on: map))").map { Embed.Image(url: $0) }
                                        ))
                                    } else {
                                        output.append(errorText: "Could not find player `\(name)` on server")
                                    }
                                } else {
                                    output.append(Embed
                                        title: "Minecraft Server Dynmap",
                                        fields: world.players?.map { Embedname: $0.name ?? "Unnamed player", value: self.describe(player: $0)) } ?? []
                                    ))
                                }
                            case .failure(let error):
                                output.append(error, errorText: "World query failed")
                        }
                    }
                case .failure(let error):
                    output.append(error, errorText: "Configuration query failed")
            }
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
