import D2MessageIO

public struct ActionResult<State: GameState> {
    public let nextState: State?
    public let text: String?
    public let files: [Message.FileUpload]
    public let cancelsMatch: Bool
    public let onlyCurrentPlayer: Bool

    public init(nextState: State? = nil, text: String? = nil, files: [Message.FileUpload] = [], cancelsMatch: Bool = false, onlyCurrentPlayer: Bool = true) {
        self.nextState = nextState
        self.text = text
        self.files = files
        self.cancelsMatch = cancelsMatch
        self.onlyCurrentPlayer = onlyCurrentPlayer
    }
}
