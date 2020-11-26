import Foundation

/** Represents the next CS/CAU games evening. */
public struct SpieleabendGoal: CountdownGoal {
    public var date: Date { return nextGamesEveningFromNow() }

    public init() {}

    private func nextGamesEveningFromNow() -> Date {
        let now = Date()
        let gamesEveningThisMonth = gamesEvening(inMonthOf: now)

        if (gamesEveningThisMonth > now) {
            return gamesEveningThisMonth
        } else {
            return gamesEvening(inMonthOf: Calendar.current.date(byAdding: .month, value: 1, to: now)!)
        }
    }

    /** The games evening occurs on the second thursday each month. */
    private func gamesEvening(inMonthOf baseDate: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: baseDate)
        components.weekday = 5
        components.weekdayOrdinal = 2
        components.hour = 18
        return calendar.date(from: components)!
    }
}
