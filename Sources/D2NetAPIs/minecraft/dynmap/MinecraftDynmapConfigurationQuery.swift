import Utils

public struct MinecraftDynmapConfigurationQuery {
    private let host: String

    public init(host: String) {
        self.host = host
    }

    public func perform() -> Promise<MinecraftDynmapConfiguration, Error> {
        Promise.catchingThen {
            let request = try HTTPRequest(scheme: "http", host: host, port: 8123, path: "/up/configuration")
            return request.fetchJSONAsync(as: MinecraftDynmapConfiguration.self)
        }
    }
}
