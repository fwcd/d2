import Foundation
import Utils

public struct MinecraftDynmapWorldQuery {
    private let host: String
    private let world: String

    public init(host: String, world: String) {
        self.host = host
        self.world = world
    }

    public func perform() -> Promise<MinecraftDynmapWorld, any Error> {
        let timestamp = Int(Date().timeIntervalSince1970)
        return Promise.catching { try HTTPRequest(scheme: "http", host: host, port: 8123, path: "/up/world/\(world)/\(timestamp)") }
            .then { $0.fetchJSONAsync(as: MinecraftDynmapWorld.self) }
    }
}
