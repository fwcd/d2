import D2MessageIO
import D2Utils

extension InteractiveTextChannel {
    public func send(image: Image) throws {
        send(try Message(fromImage: image))
    }
	
    public func send(gif: AnimatedGif) throws {
        send(try Message(fromGif: gif))
    }
}

extension Message {
    public init(fromImage image: Image, name: String? = nil) throws {
        self.init(content: "", embed: nil, files: [
            Message.FileUpload(data: try image.pngEncoded(), filename: name ?? "image.png", mimeType: "image/png")
        ], tts: false)
    }
	
    public init(fromGif gif: AnimatedGif, name: String? = nil) throws {
        self.init(content: "", embed: nil, files: [
            Message.FileUpload(data: try gif.encoded(), filename: name ?? "image.gif", mimeType: "image/gif")
        ], tts: false)
    }
}
