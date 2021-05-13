import XCTest
import Utils
import D2TestUtils
import D2MessageIO
@testable import D2Handlers

final class SpamHandlerTests: XCTestCase {
    private var tempDir: TemporaryDirectory!
    private var handler: SpamHandler!
    private var output: TestOutput!
    private var timestamp: Date!

    override func setUp() {
        tempDir = TemporaryDirectory()
        handler = SpamHandler(config: AutoSerializing(wrappedValue: .init(), filePath: "\(tempDir.url.path)/spamConfig.json"))
        output = TestOutput()
        timestamp = Date()
    }

    override func tearDown() {
        tempDir = nil // deletes it
    }

    func testNewUserSpamming() {
        spam()
        spam(after: 1)
        spam(after: 0.5)
    }

    private func spam(after interval: TimeInterval = 0) {
        timestamp += interval
        let _ = handler.handle(message: Message(content: "@everyone", mentionEveryone: true, timestamp: timestamp), from: output)
    }
}
