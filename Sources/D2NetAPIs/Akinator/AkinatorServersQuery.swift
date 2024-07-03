import Utils

// Ported from https://github.com/janniksam/Akinator.Api.Net/blob/master/Akinator.Api.Net/AkinatorServerLocator.cs
// MIT-licensed, Copyright (c) 2019 Jannik

struct AkinatorServersQuery {
    init() {}

    func perform() async throws -> AkinatorServers {
        let request = try HTTPRequest(
            host: "global3.akinator.com",
            path: "/ws/instances_v2.php",
            query: ["media_id": "14", "footprint": "cd8e6509f3420878e18d75b9831b317f", "mode": "https"]
        )
        return try await request.fetchXML(as: AkinatorServers.self)
    }
}
