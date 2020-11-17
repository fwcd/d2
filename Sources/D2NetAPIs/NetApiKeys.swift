import Utils

let storedNetApiKeys = try? DiskJsonSerializer().readJson(as: NetApiKeys.self, fromFile: "local/netApiKeys.json")

struct NetApiKeys: Codable {
    var mapQuest: String? = nil
    var tier: String? = nil
    var wolframAlpha: String? = nil
    var gitlab: String? = nil
    var openweathermap: String? = nil
    var windy: Windy? = nil

    struct Windy: Codable {
        var webcams: String? = nil
    }
}
