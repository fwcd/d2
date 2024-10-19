@globalActor
public actor CommandActor: GlobalActor {
    public static let shared = CommandActor()

    private init() {}

    /// Runs a closure on the CommandActor.
    ///
    /// See https://jaimzuber.com/swift-concurrency/run-actor-run
    public static func run<T>(resultType: T.Type = T.self, body: @CommandActor @Sendable () throws -> T) async rethrows -> T where T: Sendable {
        try await body()
    }
}
