import XCTest
import Utils
import D2TestUtils
import D2MessageIO
import D2Commands
@testable import D2Handlers

final class SpamHandlerTests: XCTestCase {
    @CommandActor
    private class Timestamp {
        var value = Date()

        func increase(by interval: TimeInterval) {
            value += interval
        }
    }

    private var timestamp: Timestamp!

    private var handler: SpamHandler!
    private var output: TestOutput!
    private var channelId: ChannelID!
    private var user: User!

    override func setUp() async throws {
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

    func testNewUserSpamming() async throws {
        await join(daysAgo: 0.2)

        var warned: Bool
        var penalized: Bool

        (warned, penalized) = await (isWarned(), isPenalized())
        XCTAssert(!warned)
        XCTAssert(!penalized)

        try await spam(after: 0.5)

        (warned, penalized) = await (isWarned(), isPenalized())
        XCTAssert(warned)
        XCTAssert(!penalized)

        try await spam(after: 0.5)

        (warned, penalized) = await (isWarned(), isPenalized())
        XCTAssert(warned)
        XCTAssert(penalized)
    }

    func testOlderUserSpamming() async throws {
        await join(daysAgo: 32)

        try await spam() // This one should be expired by the time the second one is sent
        try await spam(after: 200)
        try await spam()
        try await spam()
        try await spam()

        var warned: Bool
        var penalized: Bool

        (warned, penalized) = await (isWarned(), isPenalized())
        XCTAssert(!warned)
        XCTAssert(!penalized)

        try await spam()

        (warned, penalized) = await (isWarned(), isPenalized())
        XCTAssert(warned)
        XCTAssert(!penalized)
    }

    func testEvenOlderUserSpamming() async throws {
        await join(daysAgo: 365)

        for _ in 0..<6 {
            try await spam()
        }

        var warned: Bool
        var penalized: Bool

        (warned, penalized) = await (isWarned(), isPenalized())
        XCTAssert(!warned)
        XCTAssert(!penalized)

        try await spam()

        (warned, penalized) = await (isWarned(), isPenalized())
        XCTAssert(warned)
        XCTAssert(!penalized)

        try await spam()

        (warned, penalized) = await (isWarned(), isPenalized())
        XCTAssert(warned)
        XCTAssert(penalized)
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

    private func spam(after interval: TimeInterval = 0) async throws {
        await timestamp.increase(by: interval)
        let _ = try await handler.handle(
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
