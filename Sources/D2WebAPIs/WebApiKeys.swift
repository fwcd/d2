import D2Utils

let storedWebApiKeys = try? DiskJsonSerializer().readJson(as: WebApiKeys.self, fromFile: "local/webApiKeys.json")

struct WebApiKeys: Codable {
	var mapQuest: String? = nil
	var wolframAlpha: String? = nil
}
