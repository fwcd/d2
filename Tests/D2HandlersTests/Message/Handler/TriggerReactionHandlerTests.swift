import Testing
import Utils
import D2MessageIO
import D2TestUtils
@testable import D2Handlers

struct TriggerReactionHandlerTests {
    @Test func goodMorningReaction() async {
        #expect(await messageTriggersWeather("good mornin"))
        #expect(await messageTriggersWeather("good morning"))
        #expect(await messageTriggersWeather("guten moin"))
        #expect(await messageTriggersWeather("Guten Morgen"))
        #expect(await messageTriggersWeather("Guten   mooorgen"))
        #expect(await messageTriggersWeather("Guten Morgen, guten Morgen, guten Morgen, Sonnenschein!"))
        #expect(await messageTriggersWeather("Guten morgähn"))
        #expect(await messageTriggersWeather("Guten morgääään"))
        #expect(await messageTriggersWeather("Guten morgäääähn"))
        #expect(await messageTriggersWeather("guten müde"))
        #expect(await messageTriggersWeather("Gutsten morgen"))
        #expect(await messageTriggersWeather("Guten morjen"))
        #expect(await messageTriggersWeather("Gusten moin"))
        #expect(await messageTriggersWeather("Gjuten morgen"))
        #expect(await messageTriggersWeather("Guten Tag"))
        #expect(await messageTriggersWeather("Guten Day"))
        #expect(await messageTriggersWeather("Guten abend"))
        #expect(await messageTriggersWeather("gute nacht"))
        #expect(await messageTriggersWeather("good Night"))
        #expect(await messageTriggersWeather("Good evening"))
        #expect(await messageTriggersWeather("Juten moin"))
        #expect(await messageTriggersWeather("juuten morgen"))
        #expect(await messageTriggersWeather("guten abend"))
        #expect(await messageTriggersWeather("juuten aaaabeend"))
        // TODO: This one currently does not work, likely due to a compiler bug:
        // https://github.com/swiftlang/swift/issues/77481
        // #expect(await messageTriggersWeather("Guten Abend"))

        #expect(await !messageTriggersWeather("Moin"))
        #expect(await !messageTriggersWeather("Guten"))
        #expect(await !messageTriggersWeather("Good"))
        #expect(await !messageTriggersWeather("Morning"))
        #expect(await !messageTriggersWeather("Morgen"))
        #expect(await !messageTriggersWeather("evening"))
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
