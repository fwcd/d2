import SwiftDiscord
import D2Utils
import D2NetAPIs

public class MinecraftDynmapCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Queries the dynmap of a Minecraft server",
        longDescription: "Fetches world information from a Minecraft server running the 'dynmap' plugin",
        helpText: "Syntax: [server host]",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let host = input
        MinecraftDynmapConfigurationQuery(host: host).perform {
            switch $0 {
                case .success(let config):
                    MinecraftDynmapWorldQuery(host: host, world: config.defaultworld ?? "world").perform {
                        switch $0 {
                            case .success(let world):
                                output.append(DiscordEmbed(
                                    title: "Minecraft Server Dynmap",
                                    fields: world.players?.map { DiscordEmbed.Field(name: $0.name ?? "Unnamed player", value: """
                                        :compass: x: \($0.x ?? 0), y: \($0.y ?? 0), z: \($0.z ?? 0)
                                        \(self.formatBars(bar: ":heart:", halfBar: ":broken_heart:", value: Int($0.health ?? 0)))
                                        \(self.formatBars(bar: ":shirt:", halfBar: ":running_shirt_with_sash:", value: $0.armor ?? 0))
                                        """) } ?? []
                                ))
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
}
