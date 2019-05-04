public struct StackOverflowAnswer: Codable {
	public var body: String?
	public var bodyMarkdown: String?
	public var title: String?
	
	public enum CodingKeys: String, CodingKey {
		case body = "body"
		case bodyMarkdown = "body_markdown"
		case title = "title"
	}
}
