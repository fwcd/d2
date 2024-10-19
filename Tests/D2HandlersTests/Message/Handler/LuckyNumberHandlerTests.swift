import Testing
import D2MessageIO
import D2TestUtils
@testable import D2Handlers

struct LuckyNumberHandlerTests {
    @Test func luckyNumbers() async {
        let handler = await LuckyNumberHandler(luckyNumbers: [42])

        #expect(await !handler.isLucky(12))
        #expect(await !handler.isLucky(41))
        #expect(await handler.isLucky(42))
        #expect(await !handler.isLucky(420))
    }

    @Test func powerOfTenLuckyNumbers() async {
        let handler = await LuckyNumberHandler(luckyNumbers: [42], acceptPowerOfTenMultiples: true)

        #expect(await !handler.isLucky(12))
        #expect(await !handler.isLucky(41))
        #expect(await handler.isLucky(42))
        #expect(await handler.isLucky(420))
    }

    @Test func messageTrigger() async {
        let handler = await LuckyNumberHandler(luckyNumbers: [42])
        let output = await TestOutput()

        let message = Message(
            content: "40 is a nice number and so is 2",
            channelId: ID("Dummy Channel")
        )
        await output.modify {
            $0.messages.append(message)
        }
        _ = await handler.handle(message: message, sink: output)

        let lastContent = await output.lastContent
        #expect(lastContent == """
            All the numbers in your message added up to 42. Congrats!
            ```
            40 + 2 = 42
            ```
            """)
    }
}
