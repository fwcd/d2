import D2Utils

let storedWebApiKeys = try? DiskStorage().readJson(as: WebApiKeys.self, fromFile: "local/webApiKeys.json")

struct WebApiKeys: Codable {
	var mapQuest: String? = nil
}
