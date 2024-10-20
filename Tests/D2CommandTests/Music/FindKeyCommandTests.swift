import Testing
import D2MessageIO
import D2TestUtils
@testable import D2Commands

struct FindKeyCommandTests {
    @Test func findKey() async {
        let command = await FindKeyCommand()
        let output = await TestOutput()

        await command.testInvoke(with: .text("C"), output: output)
        #expect(await output.lastContent == "Possible keys: C Cm Db Dm Eb Em F Fm G Gm Ab Am Bb Bbm")

        await command.testInvoke(with: .text("E Eb"), output: output)
        #expect(await output.lastContent == "Possible keys: ")

        await command.testInvoke(with: .text("C Db E"), output: output)
        #expect(await output.lastContent == "Possible keys: ")

        await command.testInvoke(with: .text("C Db Eb"), output: output)
        #expect(await output.lastContent == "Possible keys: Db Fm Ab Bbm")
    }
}
