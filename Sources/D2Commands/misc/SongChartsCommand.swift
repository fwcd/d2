import SwiftDiscord
import D2Utils
import Dispatch
import Logging

fileprivate let log = Logger(label: "SongChartsCommand")

public class SongChartsCommand: StringCommand {
    public var info: CommandInfo = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the song charts on this server",
        longDescription: "Repeatedly retrieves currently playing songs to provide a chart list of popular songs on the server",
        requiredPermissionLevel: .basic
    )
    private var subcommands: [String: (CommandOutput, CommandContext) -> Void] = [:]

    @AutoSerializing(filePath: "local/songCharts.json") private var songCharts: [GuildID: GuildSongCharts] = .init()
    private let maxSongs: Int = 300

    private let queryIntervalSeconds: Int = 60
    
    public init() {
        subcommands = [
            "track": { [unowned self] output, context in
                guard let guild = context.guild else {
                    output.append(errorText: "No guild available.")
                    return
                }
                self.songCharts[guild.id] = GuildSongCharts()
                self.queryChartsAndRepeatInBackground(for: guild)
                output.append(":white_check_mark: Successfully begun to track song charts in guild `\(guild.name)`")
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
                    .map { (i, entry) in "\(i). \(entry.0) (played \(entry.1) \(plural(of: "time", ifOne: entry.1)))" }
                    .joined(separator: "\n")
            ))
        } else if let subcommand = subcommands[input] {
            subcommand(output, context)
        } else {
            output.append(errorText: "Unrecognized subcommand `\(input)`")
        }
    }

    private func plural(of str: String, ifOne value: Int) -> String {
        return (value == 1) ? str : "\(str)s"
    }

    private func queryChartsAndRepeatInBackground(for guild: DiscordGuild) {
        songCharts[guild.id]?.update { _ in
            log.info("Querying \(guild.name) for playing songs...")
            for presence in guild.presences {
                log.info("Found: \(presence)")
            }
        }

        let deadline = DispatchTime.now() + .seconds(queryIntervalSeconds)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: deadline) {
            self.queryChartsAndRepeatInBackground(for: guild)
        }
    }
    
    private func updateCharts(playedSong: GuildSongCharts.Song, guildId: GuildID) {
        songCharts[guildId]?.update {
            $0.incrementPlayCount(for: playedSong)
            $0.keepTop(n: maxSongs / 2, ifSongCountGreaterThan: maxSongs)
        }
    }
}
