import D2MessageIO
import Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.SongChartsCommand")
fileprivate let songExtractors: [String: @Sendable (Presence.Activity) -> GuildSongCharts.Song] = [
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
        requiredPermissionLevel: .vip
    )
    private var subcommands: [String: (CommandOutput, CommandContext) async -> Void] = [:]

    @AutoSerializing(filePath: "local/songCharts.json") private var songCharts: [GuildID: GuildSongCharts] = .init()
    @AutoSerializing(filePath: "local/songTrackedGuilds.json") private var trackedGuilds: Set<GuildID> = []
    private let maxSongs: Int = 300

    private let queryIntervalSeconds: Int = 60

    public init() {
        subcommands = [
            "track": { [unowned self] output, context in
                guard let guild = await context.guild else {
                    await output.append(errorText: "No guild available.")
                    return
                }
                guard !self.trackedGuilds.contains(guild.id) else {
                    await output.append(errorText: "Already tracked.")
                    return
                }
                self.trackedGuilds.insert(guild.id)
                await output.append(":white_check_mark: Successfully begun to track song charts in guild `\(guild.name)`")
            },
            "untrack": { [unowned self] output, context in
                guard let guild = await context.guild else {
                    await output.append(errorText: "No guild available.")
                    return
                }
                self.trackedGuilds.remove(guild.id)
                await output.append(":x: Successfully untracked guild `\(guild.name)`")
            },
            "tracked": { [unowned self] output, context in
                await output.append(Embed(
                    title: "Tracked Guilds",
                    description: self.trackedGuilds.asyncCompactMap { await context.sink?.guild(for: $0) }.map { $0.name }.joined(separator: "\n"),
                    footer: "Guilds for which anonymized song statistics are collected"
                ))
            },
            "clear": { [unowned self] output, context in
                guard let guild = await context.guild else {
                    await output.append(errorText: "No guild available.")
                    return
                }
                self.songCharts[guild.id] = nil
                await output.append(":wastebasket: Successfully cleared song charts for `\(guild.name)`")
            },
            "debugPresence": { [] output, context in
                guard let guild = await context.guild else {
                    await output.append("Not on a guild.")
                    return
                }
                guard let mentioned = context.message.mentions.first else {
                    await output.append("Please mention someone!")
                    return
                }
                await output.append(.compound([
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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if input.isEmpty {
            guard let charts = (context.guild?.id).flatMap({ songCharts[$0] }) else {
                await output.append(errorText: "No song charts available for this guild.")
                return
            }
            await output.append(Embed(
                title: ":star: Song Charts :musical_note:",
                description: charts.playCounts
                    .sorted { $0.value > $1.value }
                    .prefix(25)
                    .enumerated()
                    .map { (i, entry) in "\(i). \(entry.0) (played \(entry.1) \("time".pluralized(with: entry.1)))" }
                    .joined(separator: "\n")
            ))
        } else if let subcommand = subcommands[String(input.split(separator: " ")[0])] {
            await subcommand(output, context)
        } else {
            await output.append(errorText: "Unrecognized subcommand `\(input)`")
        }
    }

    public func onReceivedUpdated(presence: Presence) {
        if let guildId = presence.guildId, trackedGuilds.contains(guildId) {
            for activity in presence.activities {
                log.debug("Received activity of type \(activity.name)")

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
}
