import D2Utils
import Foundation
import SwiftSoup

public class DailyFoodMenu {
    private let request: HTTPRequest

    public init(canteen: Canteen, date: Date = Date()) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        request = try HTTPRequest(
            host: "www.studentenwerk.sh",
            path: "/de/menuAction/print.html",
            query: [
                "m": String(canteen.rawValue),
                "t": "d",
                "d": dateFormatter.string(from: date)
            ]
        )
    }
    
    public func fetchMealsAsync(then: @escaping (Result<[Meal], Error>) -> Void) {
        request.fetchUTF8Async {
            guard case let .success(html) = $0 else {
                guard case let .failure(error) = $0 else { fatalError("`Result` should always be either successful or not") }
                then(.failure(error))
                return
            }
            
            do {
                let document: Document = try SwiftSoup.parse(html)
                guard let menu = try document.getElementsByClass("menuPrint").first() else { throw FoodMenuError.noMenuPrintAvailable }
                let rows = try menu.getElementsByTag("tr").array()
                let meals: [Meal] = try rows.compactMap {
                    guard let title = try $0.getElementsByClass("item").first() else { return nil }
                    guard let properties = try $0.getElementsByClass("properties").first() else { return nil }
                    guard let price = try $0.getElementsByTag("td").last() else { return nil }
                    return Meal(
                        title: try title.text(),
                        properties: try properties.text(),
                        price: try price.text()
                    )
                }
                
                then(.success(meals))
            } catch {
                then(.failure(error))
            }
        }
    }
}
