import SwiftDiscord

public struct ActionResult<State: GameState> {
	public let nextState: State?
	public let text: String?
	public let files: [DiscordFileUpload]
	public let cancelsMatch: Bool
	public let onlyCurrentPlayer: Bool
	
	public init(nextState: State? = nil, text: String? = nil, files: [DiscordFileUpload] = [], cancelsMatch: Bool = false, onlyCurrentPlayer: Bool = true) {
		self.nextState = nextState
		self.text = text
		self.files = files
		self.cancelsMatch = cancelsMatch
		self.onlyCurrentPlayer = onlyCurrentPlayer
	}
}
