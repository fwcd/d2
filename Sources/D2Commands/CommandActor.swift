@globalActor
public struct CommandActor: GlobalActor {
    public let shared = CommandActor()

    private init() {}
}
