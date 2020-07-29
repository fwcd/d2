import D2Utils

public struct MinecraftDynmapConfigurationQuery {
    private let host: String

    public init(host: String) {
        self.host = host
    }

    public func perform() -> Promise<MinecraftDynmapConfiguration, Error> {
        do {
            let request = try HTTPRequest(scheme: "http", host: host, port: 8123, path: "/up/configuration")
            request.fetchJSONAsync(as: MinecraftDynmapConfiguration.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
