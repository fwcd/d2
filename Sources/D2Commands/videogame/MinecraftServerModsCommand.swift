import Utils
import D2MessageIO
import D2NetAPIs

public class MinecraftServerModsCommand: StringCommand {
    public let info = CommandInfo(
        category: .videogame,
        shortDescription: "Fetches a Minecraft server's modlist",
        longDescription: "Fetches a list of mods used by a given server",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        do {
            if let (host, port) = parseHostPort(from: input) {
                let serverInfo = try MinecraftServerPing(host: host, port: port ?? 25565, timeoutMs: 1000).perform()
                let modList = serverInfo.forgeData?.mods?.map { "\($0)" } ?? serverInfo.modinfo?.modList?.map { "\($0)" } ?? [String]()

                output.append(Embed(
                    title: "Minecraft Server Mods at `\(host)\(port.map { ":\($0)" } ?? "")`",
                    description: modList
                        .joined(separator: "\n")
                        .truncated(to: 1800, appending: "\n...and more")
                        .nilIfEmpty ?? "_vanilla_"
                ))
            }
        } catch {
            output.append(error, errorText: "Could not ping server")
        }
    }
}
