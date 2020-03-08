import Foundation
import SwiftDiscord
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
                                if let name = playerName {
                                    if let player = world.players?.first(where: { $0.name == name }) {
                                        output.append(DiscordEmbed(
                                            title: "Minecraft Player `\(name)`",
                                            description: self.describe(player: player),
                                            image: URL(string: "http://\(host):8123/\(self.tilePath(for: player))").map { DiscordEmbed.Image(url: $0) }
                                        ))
                                    } else {
                                        output.append(errorText: "Could not find player `\(name)` on server")
                                    }
                                } else {
                                    output.append(DiscordEmbed(
                                        title: "Minecraft Server Dynmap",
                                        fields: world.players?.map { DiscordEmbed.Field(name: $0.name ?? "Unnamed player", value: self.describe(player: $0)) } ?? []
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
    
    private func tilePath(for player: MinecraftDynmapWorld.Player, zoomLevel: Int = 2) -> String {
        let zoom = String(repeating: "z", count: zoomLevel)
        let gridSize = 1 << zoomLevel
        let gridX = Int(player.x ?? 0) / gridSize
        let gridZ = Int(player.z ?? 0) / gridSize
        let x = gridX * gridSize
        let z = gridZ * gridSize
        return "tiles/\(player.world ?? "world")/flat/0_0/\(zoom)_\(x)_\(z).png"
    }
}
