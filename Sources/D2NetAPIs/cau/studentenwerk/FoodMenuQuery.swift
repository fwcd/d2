import Utils
import Foundation
import SwiftSoup

fileprivate let mealPropertyIconPattern = try! Regex(from: "iconProp_(\\w+)\\.")

public struct FoodMenuQuery {
    private let request: HTTPRequest
    private let day: String
    private let canteen: Canteen

    public init(canteen: Canteen, date: Date = Date()) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        day = dateFormatter.string(from: date)
        request = try HTTPRequest(
            host: "studentenwerk.sh",
            path: "/de/mensen-in-kiel",
            query: [
                "ort": "1",
                "mensa": String(canteen.rawValue),
            ]
        )
        self.canteen = canteen
    }

    public func fetchMenusAsync() -> Promise<[String: FoodMenu], any Error> {
        return request.fetchHTMLAsync()
            .mapCatching { document in
                guard let menu = try document.select(".tag_headline[data-day=\(day)]").first() else { throw FoodMenuError.noMenuPrintAvailable }
                let rows = try menu.getElementsByClass("mensa_menu_detail").array()
                let meals: [(subcanteen: String, meal: Meal)] = try rows.compactMap {
                    let subcanteen = (try? $0.getElementsByClass("menu_art").text()) ?? canteen.name
                    guard let title = try $0.getElementsByClass("menu_name").first() else { return nil }
                    guard let price = try $0.getElementsByClass("menu_preis").first() else { return nil }
                    let images = try $0.getElementsByTag("img").array()
                    return (
                        subcanteen: subcanteen,
                        meal: Meal(
                            title: try title.text(),
                            properties: try images.compactMap { self.parseMealProperty(iconSrc: try $0.attr("src")) },
                            price: try price.text()
                        )
                    )
                }
                let grouped = Dictionary(grouping: meals, by: \.subcanteen).mapValues { FoodMenu(meals: $0.map(\.meal)) }
                return grouped
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
