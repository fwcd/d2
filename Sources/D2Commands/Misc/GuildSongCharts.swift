struct GuildSongCharts: Sendable, Codable {
    var playCounts: [Song: Int] = [:]

    struct Song: Codable, Hashable, CustomStringConvertible {
        let title: String?
        let album: String?
        let artist: String?
        var description: String { "\(title ?? "?") by \(artist ?? "?")" }
    }

    mutating func keepTop(n: Int, ifSongCountGreaterThan maxSongs: Int) {
        if playCounts.count > maxSongs {
            let sorted: [(Song, Int)] = playCounts.sorted { $0.value > $1.value }
            playCounts = Dictionary(uniqueKeysWithValues: sorted.prefix(n))
        }
    }

    mutating func incrementPlayCount(for song: Song) {
        let previous = playCounts[song] ?? 0
        playCounts[song] = previous + 1
    }

    mutating func update(updater: (inout Self) -> Void) {
        updater(&self)
    }
}
