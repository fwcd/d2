import XCTest
import Utils
import D2MessageIO
import D2TestUtils
@testable import D2Handlers

final class TriggerReactionHandlers: XCTestCase {
    func testGoodMorningReaction() async {
        assert(!(await messageTriggersWeather("good mornin")))
        assert(!(await messageTriggersWeather("Moin")))
        assert(await messageTriggersWeather("good morning"))
        assert(await messageTriggersWeather("guten moin"))
        assert(await messageTriggersWeather("Guten Morgen"))
        assert(await messageTriggersWeather("Guten   mooorgen"))
        assert(await messageTriggersWeather("Guten Morgen, guten Morgen, guten Morgen, Sonnenschein!"))
    }

    private func assert(_ condition: Bool, line: UInt = #line) {
        XCTAssert(condition, line: line)
    }

    private func messageTriggersWeather(_ content: String) async -> Bool {
        let emoji = ":test:"
        let handler = await TriggerReactionHandler($configuration: .constant(
            TriggerReactionConfiguration(
                dateSpecificReactions: false,
                weatherReactions: true
            )
        )) {
            emoji
        }
        let output = await TestOutput()
        let message = Message(
            content: content,
            channelId: ID("Dummy Channel"),
            id: ID("Dummy Message")
        )
        await output.modify {
            $0.messages.append(message)
        }
        _ = await handler.handle(message: message, sink: output)
        return await output.lastReactions.contains { $0.emoji.name == emoji }
    }
}
