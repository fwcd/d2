import Testing
@testable import D2Commands

struct MorseCoderTests {
    @Test func morseCoder() throws {
        let input = "the quick brown fox jumps over the lazy dog."
        let output = morseEncode(input)

        #expect(output == "- .... .   --.- ..- .. -.-. -.-   -... .-. --- .-- -.   ..-. --- -..-   .--- ..- -- .--. ...   --- ...- . .-.   - .... .   .-.. .- --.. -.--   -.. --- --. .-.-.-")
        #expect(morseDecode(output) == input)
    }
}
