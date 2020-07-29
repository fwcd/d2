import D2Utils
import Foundation
import SwiftSoup

fileprivate let mealPropertyIconPattern = try! Regex(from: "iconProp_(\\w+)\\.")

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

    public func fetchMealsAsync() -> Promise<[Meal], Error> {
        request.fetchHTMLAsync { result in
            then(Result {
                let document: Document = try result.get()
                guard let menu = try document.getElementsByClass("menuPrint").first() else { throw FoodMenuError.noMenuPrintAvailable }
                let rows = try menu.getElementsByTag("tr").array()
                let meals: [Meal] = try rows.compactMap {
                    guard let title = try $0.getElementsByClass("item").first() else { return nil }
                    guard let properties = try $0.getElementsByClass("properties").first() else { return nil }
                    guard let price = try $0.getElementsByTag("td").last() else { return nil }
                    return Meal(
                        title: try title.text(),
                        properties: try properties.getElementsByTag("img").array().compactMap { self.parseMealProperty(iconSrc: try $0.attr("src")) },
                        price: try price.text()
                    )
                }
                return meals
            })
        }
    }

    private func parseMealProperty(iconSrc: String) -> MealProperty? {
        mealPropertyIconPattern.firstGroups(in: iconSrc).flatMap {
            switch $0[1] {
                case "g": return .chicken
                case "r": return .beef
                case "s": return .pork
                case "vegetarisch": return .vegetarian
                case "vegan": return .vegan
                default: return nil
            }
        }
    }
}
