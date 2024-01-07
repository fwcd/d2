import XCTest
import Utils
import D2TestUtils
import D2MessageIO
import D2Commands
@testable import D2Handlers

final class SpamHandlerTests: XCTestCase {
    private var handler: SpamHandler!
    private var output: TestOutput!
    private var timestamp: Date!
    private var channelId: ChannelID!
    private var user: User!

    override func setUp() {
        timestamp = Date()
        @Box var config = SpamConfiguration()
        handler = SpamHandler(config: $config) { [unowned self] in
            timestamp
        }
        output = TestOutput()
        user = User(id: UserID("0", clientName: output.name), username: "Jochen Zimmermann")
        channelId = ChannelID("0")
    }

    func testNewUserSpamming() {
        join(daysAgo: 0.2)

        XCTAssert(!isWarned())
        XCTAssert(!isPenalized())

        spam(after: 0.5)

        XCTAssert(isWarned())
        XCTAssert(!isPenalized())

        spam(after: 0.5)

        XCTAssert(isWarned())
        XCTAssert(isPenalized())
    }

    func testOlderUserSpamming() {
        join(daysAgo: 32)

        spam() // This one should be expired by the time the second one is sent
        spam(after: 200)
        spam()
        spam()
        spam()

        XCTAssert(!isWarned())
        XCTAssert(!isPenalized())

        spam()

        XCTAssert(isWarned())
        XCTAssert(!isPenalized())
    }

    func testEvenOlderUserSpamming() {
        join(daysAgo: 365)

        for _ in 0..<6 {
            spam()
        }

        XCTAssert(!isWarned())
        XCTAssert(!isPenalized())

        spam()

        XCTAssert(isWarned())
        XCTAssert(!isPenalized())

        spam()

        XCTAssert(isWarned())
        XCTAssert(isPenalized())
    }

    private func join(daysAgo: Double) {
        let guildId = GuildID("")
        let channel = Channel(id: channelId, guildId: guildId, name: "Test channel")
        let member = Guild.Member(guildId: guildId, joinedAt: Date() - TimeInterval(daysAgo * 86400), user: user)
        let guild = Guild(id: guildId, name: "Test guild", members: [user.id: member], channels: [channelId: channel])
        output.guilds!.append(guild)
    }

    private func spam(after interval: TimeInterval = 0) {
        timestamp += interval
        let _ = handler.handle(message: Message(content: "@everyone", author: user, channelId: channelId, mentionEveryone: true, timestamp: timestamp), sink: output)
    }

    private func isWarned() -> Bool {
        output.contents.contains { $0.contains("Please stop spamming") }
    }

    private func isPenalized() -> Bool {
        output.contents.contains { $0.contains("Penalizing") }
    }
}
