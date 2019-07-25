import SwiftDiscord
import Foundation

extension DiscordTextChannel {
	public func send(_ message: String) {
		send(DiscordMessage(content: message))
	}
	
	public func send(embed: DiscordEmbed) {
		send(DiscordMessage(fromEmbed: embed))
	}
}

extension DiscordMessageLikeInitializable {
	public init(fromContent content: String) {
		self.init(content: content, embed: nil, files: [], tts: false)
	}
	
	public init(fromEmbed embed: DiscordEmbed?) {
		self.init(content: "", embed: embed, files: [], tts: false)
	}
	
	public init(fromFiles files: [DiscordFileUpload]) {
		self.init(content: "", embed: nil, files: files, tts: false)
	}
}

extension DiscordAttachment {
	/**
	 * Downloads the attachment asynchronously.
	 */
	public func download(then: @escaping (Result<Data, Error>) -> Void) {
		URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
			guard error == nil else {
				then(.failure(URLRequestError.ioError(error!)))
				return
			}
			guard let data = data else {
				then(.failure(URLRequestError.missingData))
				return
			}
			then(.success(data))
		}.resume()
	}
}
