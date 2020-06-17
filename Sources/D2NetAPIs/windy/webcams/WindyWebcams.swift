public struct WindyWebcams: Codable {
    public let offset: Int
    public let limit: Int
    public let total: Int
    public let webcams: [Webcam]

    public struct Webcam: Codable {
        public let id: String
        public let status: String
        public let title: String
    }
}
