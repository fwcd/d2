import Utils

public struct MinecraftDynmapConfigurationQuery {
    private let host: String

    public init(host: String) {
        self.host = host
    }

    public func perform() async throws -> MinecraftDynmapConfiguration {
        let request = try HTTPRequest(scheme: "http", host: host, port: 8123, path: "/up/configuration")
        return try await request.fetchJSON(as: MinecraftDynmapConfiguration.self)
    }
}
