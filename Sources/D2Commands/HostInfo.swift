/// Information about the host running D2.
public struct HostInfo: Hashable, Codable {
    public var displayName: String?

    public init(displayName: String? = nil) {
        self.displayName = displayName
    }
}
