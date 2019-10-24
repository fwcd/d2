import Foundation
import SwiftDiscord
import D2Permissions

/** Fetches the time until the next CS/CAU games evening. */
public class SpieleabendCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Countdown to the next CAU/CS games evening",
        longDescription: "Fetches the time remaining until the next games evening by the CAU's CS student council takes place.",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let nextGamesEvening = nextGamesEveningFromNow()
        let timeUntilNextGamesEvening = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: nextGamesEvening)
        let days = timeUntilNextGamesEvening.day!
        let hours = timeUntilNextGamesEvening.hour!
        let minutes = timeUntilNextGamesEvening.minute!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"

        output.append(.embed(DiscordEmbed(
            title: ":game_die: Spieleabend",
            description: "The next Spieleabend will take place in **\(days) \(plural(of: "day", ifOne: days)), \(hours) \(plural(of: "hour", ifOne: hours)) and \(minutes) \(plural(of: "minute", ifOne: minutes))**",
            footer: DiscordEmbed.Footer(text: dateFormatter.string(from: nextGamesEvening))
        )))
    }
    
    private func plural(of str: String, ifOne value: Int) -> String {
        return (value == 1) ? str : "\(str)s"
    }
    
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
