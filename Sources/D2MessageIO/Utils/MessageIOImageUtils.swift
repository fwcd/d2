import Utils
@preconcurrency import CairoGraphics
@preconcurrency import GIF

extension InteractiveTextChannel {
    public func send(image: CairoImage) async throws {
        try await send(Message(fromImage: image))
    }

    public func send(gif: GIF) async throws {
        try await send(Message(fromGif: gif))
    }
}

extension Message {
    public init(fromImage image: CairoImage, name: String? = nil) throws {
        self.init(content: "", embed: nil, files: [
            Message.FileUpload(data: try image.pngEncoded(), filename: name ?? "image.png", mimeType: "image/png")
        ], tts: false)
    }

    public init(fromGif gif: GIF, name: String? = nil) throws {
        self.init(content: "", embed: nil, files: [
            Message.FileUpload(data: try gif.encoded(), filename: name ?? "image.gif", mimeType: "image/gif")
        ], tts: false)
    }
}
