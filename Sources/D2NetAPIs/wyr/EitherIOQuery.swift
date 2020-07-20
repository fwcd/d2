import D2Utils
import SwiftSoup

public struct EitherIOQuery {
    private let term: String
    private let maxOffset: Int

    public init(
        term: String,
        maxOffset: Int
    ) {
        self.term = term
        self.maxOffset = maxOffset
    }

    private struct EitherIOResponse: Codable {
        enum CodingKeys: String, CodingKey {
            case activity
            case showMore = "show_more"
        }

        let activity: String
        let showMore: Bool
    }

    public func perform(offset: Int = 0, prepending: [WouldYouRatherQuestion] = [], then: @escaping (Result<[WouldYouRatherQuestion], Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "either.io", path: "/search", query: ["s": term, "offset": String(offset)])
            request.fetchJSONAsync(as: EitherIOResponse.self) {
                do {
                    let response = try $0.get()
                    let node = try SwiftSoup.parseBodyFragment(response.activity)
                    let questions: [WouldYouRatherQuestion] = try node.getElementsByTag("p").array().compactMap {
                        let choices = try $0.getElementsByTag("strong").array()
                        guard
                            let title = $0.textNodes().first?.text(),
                            let firstChoice = try choices[safely: 0]?.text(),
                            let secondChoice = try choices[safely: 1]?.text() else { return nil }
                        return WouldYouRatherQuestion(
                            title: title,
                            firstChoice: firstChoice,
                            secondChoice: secondChoice
                        )
                    }

                    if response.showMore && offset < maxOffset {
                        perform(offset: offset + questions.count, prepending: prepending + questions, then: then)
                    } else {
                        then(.success(prepending + questions))
                    }
                } catch {
                    then(.failure(error))
                }
            }
        } catch {
            then(.failure(error))
        }
    }
}
