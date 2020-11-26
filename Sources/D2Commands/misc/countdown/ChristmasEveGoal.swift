import Foundation

/** Represents the next christmas eve. */
public struct ChristmasEveGoal: CountdownGoal {
    public var date: Date { nextChristmasFromNow() }

    public init() {}

    private func nextChristmasFromNow() -> Date {
        let now = Date()
        let christmasEveThisYear = christmasEve(inYearOf: now)

        if (christmasEveThisYear > now) {
            return christmasEveThisYear
        } else {
            return christmasEve(inYearOf: Calendar.current.date(byAdding: .year, value: 1, to: now)!)
        }
    }

    private func christmasEve(inYearOf baseDate: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: baseDate)
        components.day = 24
        components.month = 12
        return calendar.date(from: components)!
    }
}
