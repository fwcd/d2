import Foundation

/** Represents the next new year's eve. */
public struct NewYearsEveGoal: CountdownGoal {
    public var date: Date { nextNewYearsEveFromNow() }

    public init() {}

    private func nextNewYearsEveFromNow() -> Date {
        let now = Date()
        let newYearsEveThisYear = newYearsEve(inYearOf: now)

        if (newYearsEveThisYear > now) {
            return newYearsEveThisYear
        } else {
            return newYearsEve(inYearOf: Calendar.current.date(byAdding: .year, value: 1, to: now)!)
        }
    }

    private func newYearsEve(inYearOf baseDate: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: baseDate)
        components.day = 31
        components.month = 12
        return calendar.date(from: components)!
    }
}
