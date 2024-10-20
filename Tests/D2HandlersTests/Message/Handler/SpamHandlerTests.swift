import Foundation
import Testing
import Utils
import D2TestUtils
import D2MessageIO
import D2Commands
@testable import D2Handlers

struct SpamHandlerTests {
    @CommandActor
    private class Timestamp {
        var value = Date()

        func increase(by interval: TimeInterval) {
            value += interval
        }
    }

    private let timestamp: Timestamp
    private var handler: SpamHandler
    private let output: TestOutput
    private let channelId: ChannelID
    private let user: User

    init() async {
        let timestamp = Timestamp()
        self.timestamp = timestamp
        @Box var config = SpamConfiguration()
        handler = await SpamHandler($config: $config) {
            timestamp.value
        }
        output = await TestOutput()
        user = User(id: UserID("0", clientName: output.name), username: "Jochen Zimmermann")
        channelId = ChannelID("0")
    }

    @Test mutating func newUserSpamming() async {
        await join(daysAgo: 0.2)

        #expect(await !isWarned())
        #expect(await !isPenalized())

        await spam(after: 0.5)

        #expect(await isWarned())
        #expect(await !isPenalized())

        await spam(after: 0.5)

        #expect(await isWarned())
        #expect(await isPenalized())
    }

    @Test mutating func olderUserSpamming() async {
        await join(daysAgo: 32)

        await spam() // This one should be expired by the time the second one is sent
        await spam(after: 200)
        await spam()
        await spam()
        await spam()

        #expect(await !isWarned())
        #expect(await !isPenalized())

        await spam()

        #expect(await isWarned())
        #expect(await !isPenalized())
    }

    @Test mutating func evenOlderUserSpamming() async {
        await join(daysAgo: 365)

        for _ in 0..<6 {
            await spam()
        }

        #expect(await !isWarned())
        #expect(await !isPenalized())

        await spam()

        #expect(await isWarned())
        #expect(await !isPenalized())

        await spam()

        #expect(await isWarned())
        #expect(await isPenalized())
    }

    private func join(daysAgo: Double) async {
        let guildId = GuildID("")
        let channel = Channel(id: channelId, guildId: guildId, name: "Test channel")
        let member = Guild.Member(guildId: guildId, joinedAt: Date() - TimeInterval(daysAgo * 86400), user: user)
        let guild = Guild(id: guildId, name: "Test guild", members: [user.id: member], channels: [channelId: channel])
        await output.modify {
            $0.guilds!.append(guild)
        }
    }

    private mutating func spam(after interval: TimeInterval = 0) async {
        await timestamp.increase(by: interval)
        let _ = await handler.handle(
            message: Message(
                content: "@everyone",
                author: user,
                channelId: channelId,
                mentionEveryone: true,
                timestamp: timestamp.value
            ),
            sink: output
        )
    }

    private func isWarned() async -> Bool {
        await output.contents.contains { $0.contains("Please stop spamming") }
    }

    private func isPenalized() async -> Bool {
        await output.contents.contains { $0.contains("Penalizing") }
    }
}
