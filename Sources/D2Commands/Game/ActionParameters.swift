public struct ActionParameters<State: GameState> {
    public var args: String = ""
    public var state: State
    public var apiEnabled: Bool = false
    public var player: GamePlayer
    public var channelName: String? = nil
}
