import Utils

let storedNetApiKeys = try? DiskJsonSerializer().readJson(as: NetApiKeys.self, fromFile: "local/netApiKeys.json")

struct NetApiKeys: Sendable, Codable {
    var mapQuest: String? = nil
    var tier: String? = nil
    var wolframAlpha: String? = nil
    var gitlab: String? = nil
    var openweathermap: String? = nil
    var windy: Windy? = nil
    var adventOfCode: [String: String]? = nil
    var giphy: String? = nil
    var nasa: String? = nil

    struct Windy: Sendable, Codable {
        var webcams: String? = nil
    }
}
