import D2Utils

public struct MinecraftDynmapWorldQuery {
    private let host: String
    private let world: String
    
    public init(host: String, world: String) {
        self.host = host
        self.world = world
    }
    
    public func perform(then: @escaping (Result<MinecraftDynmapWorld, Error>) -> Void) {
        do {
            let request = try HTTPRequest(scheme: "http", host: host, port: 8123, path: "/up/world/\(world)/0")
            request.fetchJSONAsync(as: MinecraftDynmapWorld.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
