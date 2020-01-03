import SwiftDiscord

public class MinecraftServerPingCommand: StringCommand {
    public let info = CommandInfo(
        category: .minecraft,
        shortDescription: "Pings a Minecraft Server",
        longDescription: "Fetches the Message of the Day (MOTD) and the current player list of a Minecraft Server",
        requiredPermissionLevel: .vip
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
