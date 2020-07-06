import D2Utils
import SwiftSoup

public struct WouldYouRatherQuery {
    private let category: String

    public init(category: String) {
        self.category = category
    }
    
    public func perform(then: @escaping (Result<[WouldYouRatherQuestion], Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "www.rrrather.com", path: "/\(category)")
            request.fetchHTMLAsync { result in
                then(Result {
                    let document: Document = try result.get()
                    let rawQuestions = try document.select(".questions > li").array().flatMap { try $0.getElementsByTag("li").array() }
                    let questions: [WouldYouRatherQuestion] = try rawQuestions.compactMap {
                        let options = try $0.getElementsByClass("option")
                        guard
                            let title = $0.textNodes().first?.text(),
                            let firstChoice = try options[safely: 0]?.text(),
                            let secondChoice = try options[safely: 1]?.text() else { return nil }
                        
                        return WouldYouRatherQuestion(
                            title: title,
                            firstChoice: firstChoice,
                            secondChoice: secondChoice,
                            explanation: try $0.getElementsByClass("explanation").first()?.text()
                        )
                    }
                    return questions
                })
            }
        } catch {
            then(.failure(error))
        }
    }
}
