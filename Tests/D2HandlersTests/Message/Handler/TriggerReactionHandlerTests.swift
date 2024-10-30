import Testing
import Utils
import D2MessageIO
import D2TestUtils
@testable import D2Handlers

struct TriggerReactionHandlerTests {
    @Test func goodMorningReaction() async {
        #expect(await !messageTriggersWeather("good mornin"))
        #expect(await !messageTriggersWeather("Moin"))
        #expect(await messageTriggersWeather("good morning"))
        #expect(await messageTriggersWeather("guten moin"))
        #expect(await messageTriggersWeather("Guten Morgen"))
        #expect(await messageTriggersWeather("Guten   mooorgen"))
        #expect(await messageTriggersWeather("Guten Morgen, guten Morgen, guten Morgen, Sonnenschein!"))
        #expect(await messageTriggersWeather("Guten morgähn"))
        #expect(await messageTriggersWeather("Guten morgääään"))
        #expect(await messageTriggersWeather("Guten morgäääähn"))
        #expect(await messageTriggersWeather("guten müde"))
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
