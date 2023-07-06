import XCTest
import Utils
import D2MessageIO
import D2TestUtils
@testable import D2Handlers

final class TriggerReactionHandlers: XCTestCase {
    func testGoodMorningReaction() {
        XCTAssertFalse(messageTriggersWeather("good mornin"))
        XCTAssertFalse(messageTriggersWeather("Moin"))
        XCTAssert(messageTriggersWeather("good morning"))
        XCTAssert(messageTriggersWeather("guten moin"))
        XCTAssert(messageTriggersWeather("Guten Morgen"))
        XCTAssert(messageTriggersWeather("Guten   mooorgen"))
        XCTAssert(messageTriggersWeather("Guten Morgen, guten Morgen, guten Morgen, Sonnenschein!"))
    }

    private func messageTriggersWeather(_ content: String) -> Bool {
        let emoji = ":test:"
        let handler = TriggerReactionHandler(dateSpecificReactions: false) {
            Promise(emoji)
        }
        let output = TestOutput()
        let message = Message(
            content: content,
            channelId: ID("Dummy Channel"),
            id: ID("Dummy Message")
        )
        output.messages.append(message)
        _ = handler.handle(message: message, from: output)
        return output.lastReactions.contains { $0.emoji.name == emoji }
    }
}
