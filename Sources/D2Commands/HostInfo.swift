/// Information about the host running D2.
public struct HostInfo: Sendable, Hashable, Codable {
    public var instanceName: String?

    public init(instanceName: String? = nil) {
        self.instanceName = instanceName
    }
}
