import SwiftDiscord
import D2Utils
import Logging

fileprivate let log = Logger(label: "SongChartsCommand")
fileprivate let songExtractors: [String: (DiscordActivity) -> GuildSongCharts.Song] = [
    "Spotify": { .init(
        title: $0.details,
        album: $0.assets?.largeText,
        artist: $0.state
    ) }
]

public class SongChartsCommand: StringCommand {
    public var info: CommandInfo = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the song charts on this server",
        longDescription: "Repeatedly retrieves currently playing songs to provide a chart list of popular songs on the server",
        requiredPermissionLevel: .basic
    )
    private var subcommands: [String: (CommandOutput, CommandContext) -> Void] = [:]

    @AutoSerializing(filePath: "local/songCharts.json") private var songCharts: [GuildID: GuildSongCharts] = .init()
    @AutoSerializing(filePath: "local/songTrackedGuilds.json") private var trackedGuilds: Set<GuildID> = []
    private let maxSongs: Int = 300

    private let queryIntervalSeconds: Int = 60
    
    public init() {
        subcommands = [
            "track": { [unowned self] output, context in
                guard let guild = context.guild else {
                    output.append(errorText: "No guild available.")
                    return
                }
                guard !self.trackedGuilds.contains(guild.id) else {
                    output.append(errorText: "Already tracked.")
                    return
                }
                self.trackedGuilds.insert(guild.id)
                output.append(":white_check_mark: Successfully begun to track song charts in guild `\(guild.name)`")
            },
            "untrack": { [unowned self] output, context in
                guard let guild = context.guild else {
                    output.append(errorText: "No guild available.")
                    return
                }
                self.trackedGuilds.remove(guild.id)
                output.append(":x: Successfully untracked guild `\(guild.name)`")
            },
            "tracked": { [unowned self] output, context in
                output.append(DiscordEmbed(
                    title: "Tracked Guilds",
                    description: self.trackedGuilds.compactMap { context.client?.guilds[$0] }.map { $0.name }.joined(separator: "\n"),
                    footer: DiscordEmbed.Footer(text: "Guilds for which anonymized song statistics are collected")
                ))
            },
            "clear": { [unowned self] output, context in
                guard let guild = context.guild else {
                    output.append(errorText: "No guild available.")
                    return
                }
                self.songCharts[guild.id] = nil
                output.append(":wastebasket: Successfully cleared song charts for `\(guild.name)`")
            },
            "debugPresence": { [] output, context in
                guard let guild = context.guild else {
                    output.append("Not on a guild.")
                    return
                }
                guard let mentioned = context.message.mentions.first else {
                    output.append("Please mention someone!")
                    return
                }
                output.append(.compound([
                    .text("User `\(mentioned.username)` has the presence:"),
                    .code(guild.presences[mentioned.id].map { "\($0)" } ?? "nil", language: "swift")
                ]))
            }
        ]
        info.helpText = """
            Subcommands:
            
            \(subcommands.keys.map { "- \($0)" }.joined(separator: "\n"))
            """
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        if input.isEmpty {
            guard let charts = (context.guild?.id).flatMap({ songCharts[$0] }) else {
                output.append(errorText: "No song charts available for this guild.")
                return
            }
            output.append(DiscordEmbed(
                title: ":star: Song Charts :musical_note:",
                description: charts.playCounts
                    .sorted { $0.value > $1.value }
                    .prefix(25)
                    .enumerated()
                    .map { (i, entry) in "\(i). \(entry.0) (played \(entry.1) \("time".pluralize(with: entry.1)))" }
                    .joined(separator: "\n")
            ))
        } else if let subcommand = subcommands[String(input.split(separator: " ")[0])] {
            subcommand(output, context)
        } else {
            output.append(errorText: "Unrecognized subcommand `\(input)`")
        }
    }

    public func onReceivedUpdated(presence: DiscordPresence) {
        let guildId = presence.guildId
        if trackedGuilds.contains(guildId), let activity = presence.game {
            log.debug("Received presence of type \(activity.name)")

            if let songExtractor = songExtractors[activity.name] {
                var charts = songCharts[guildId] ?? GuildSongCharts()
                let song = songExtractor(activity)

                charts.incrementPlayCount(for: song)
                charts.keepTop(n: maxSongs / 2, ifSongCountGreaterThan: maxSongs)
                log.info("Incremented play count for \(song)")

                songCharts[guildId] = charts
            }
        }
    }
}
