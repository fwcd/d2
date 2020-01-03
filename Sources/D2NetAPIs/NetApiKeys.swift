import D2Utils

let storedNetApiKeys = try? DiskJsonSerializer().readJson(as: NetApiKeys.self, fromFile: "local/netApiKeys.json")

struct NetApiKeys: Codable {
	var mapQuest: String? = nil
	var wolframAlpha: String? = nil
}
