public struct StackOverflowQuestion: Codable {
    public var body: String?
    public var bodyMarkdown: String?
    public var tags: [String]?
    public var owner: StackOverflowShallowUser?
    public var isAnswered: String?
    public var viewCount: String?
    public var acceptedAnswerId: Int?
    public var answerCount: Int?
    public var score: Int?
    public var lastActivityDate: UInt?
    public var creationDate: UInt?
    public var lastEditDate: UInt?
    public var questionId: Int?
    public var link: String?
    public var title: String?

    public enum CodingKeys: String, CodingKey {
        case body = "body"
        case bodyMarkdown = "body_markdown"
        case owner = "owner"
        case isAnswered = "is_answered"
        case viewCount = "view_count"
        case acceptedAnswerId = "accepted_answer_id"
        case answerCount = "answer_count"
        case score = "score"
        case lastActivityDate = "last_activity_date"
        case creationDate = "creation_date"
        case lastEditDate = "last_edit_date"
        case questionId = "question_id"
        case link = "link"
        case title = "title"
    }
}
