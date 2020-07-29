import Logging
import D2Utils
import SwiftSoup

fileprivate let log = Logger(label: "D2NetAPIs.EitherIOQuery")

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

    public func perform(offset: Int = 0, prepending: [WouldYouRatherQuestion] = [], ) -> Promise<[WouldYouRatherQuestion], Error> {
        do {
            log.info("Querying '\(term)' with offset \(offset) from either.io")
            let request = try HTTPRequest(host: "either.io", path: "/search", query: ["s": term, "offset": String(offset)], headers: ["X-Requested-With": "XMLHttpRequest"])
            request.fetchJSONAsync(as: EitherIOResponse.self) {
                do {
                    let response = try $0.get()
                    let node = try SwiftSoup.parseBodyFragment(response.activity)
                    let questions: [WouldYouRatherQuestion] = try node.getElementsByTag("p").array().compactMap {
                        let choices = try $0.getElementsByTag("strong").array()
                        guard
                            let title = $0.textNodes().first?.text().trimmingCharacters(in: .whitespacesAndNewlines),
                            let firstChoice = try choices[safely: 0]?.text().trimmingCharacters(in: .whitespacesAndNewlines),
                            let secondChoice = try choices[safely: 1]?.text().trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
                        return WouldYouRatherQuestion(
                            title: title,
                            firstChoice: firstChoice,
                            secondChoice: secondChoice
                        )
                    }

                    if response.showMore && offset < self.maxOffset {
                        self.perform(offset: offset + questions.count, prepending: prepending + questions, then: then)
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
